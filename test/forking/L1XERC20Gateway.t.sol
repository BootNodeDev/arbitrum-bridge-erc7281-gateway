// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";
// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { L1GatewayRouter } from "@arbitrum/tokenbridge/ethereum/gateway/L1GatewayRouter.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";

import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

contract L1XERC20GatewayTest is Test {
    uint256 internal mainnetFork;

    XERC20 internal xerc20;
    L1XERC20Adapter internal adapter;

    address internal _owner = makeAddr("owner");
    address internal _minter = makeAddr("minter");
    address internal _user = makeAddr("user");

    address internal l1GatewayRouter = 0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef;
    address internal l1Inbox = 0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f;
    L1XERC20Gateway internal l1Gateway;

    address internal l2TokenAddress = makeAddr("l2TokenAddress");

    uint256 public maxSubmissionCost = 20;
    uint256 public maxGas = 1_000_000_000;
    uint256 public gasPriceBid = 1_000_000_000;
    uint256 public nativeTokenTotalFee = gasPriceBid * maxGas;
    uint256 public retryableCost = maxSubmissionCost + nativeTokenTotalFee;

    function setUp() public {
        vm.label(l1GatewayRouter, "l1GatewayRouter");

        mainnetFork = vm.createSelectFork("mainnet", 19_690_420);

        l1Gateway = new L1XERC20Gateway(l1GatewayRouter, l1Inbox);

        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);
        vm.deal(_owner, 100 ether);

        vm.prank(_owner);
        adapter = new L1XERC20Adapter(address(xerc20), address(l1Gateway));

        vm.prank(_owner);
        xerc20.setLimits(_minter, 42 ether, 0);

        vm.fee(0);
    }

    function test_RegisterTokenOnL2() public {
        vm.prank(_owner);
        adapter.registerTokenOnL2{ value: 3 ether }(
            l2TokenAddress,
            maxSubmissionCost,
            maxSubmissionCost,
            maxGas,
            maxGas,
            gasPriceBid,
            retryableCost,
            retryableCost,
            makeAddr("creditBackAddr")
        );

        L1GatewayRouter router = L1GatewayRouter(l1GatewayRouter);
        assertEq(router.getGateway(address(adapter)), address(l1Gateway));
        assertEq(router.calculateL2TokenAddress(address(adapter)), l2TokenAddress);
    }

    function test_OutboundTransferCustomRefund() public {
        vm.prank(_owner);
        adapter.registerTokenOnL2{ value: 3 ether }(
            l2TokenAddress,
            maxSubmissionCost,
            maxSubmissionCost,
            maxGas,
            maxGas,
            gasPriceBid,
            retryableCost,
            retryableCost,
            makeAddr("creditBackAddr")
        );

        vm.prank(_minter);
        xerc20.mint(_user, 10 ether);

        vm.prank(_owner);
        xerc20.setLimits(address(l1Gateway), 0, 42 ether);

        vm.prank(_user);
        xerc20.approve(address(l1Gateway), 1 ether);

        address dest = makeAddr("dest");
        L1GatewayRouter router = L1GatewayRouter(l1GatewayRouter);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(_user, address(0), 1 ether);

        vm.expectEmit(true, true, true, true, address(l1Gateway));
        emit DepositInitiated(address(adapter), _user, dest, 1_487_345, 1 ether);

        vm.deal(_user, 10 ether);
        vm.prank(_user);
        router.outboundTransferCustomRefund{ value: 3 ether }(
            address(adapter), dest, dest, 1 ether, maxGas, gasPriceBid, abi.encode(maxSubmissionCost, "")
        );

        assertEq(adapter.balanceOf(_user), xerc20.balanceOf(_user));
        assertEq(xerc20.balanceOf(_user), 9 ether);
    }

    ////
    // Event declarations for assertions
    ////
    event Transfer(address indexed from, address indexed to, uint256 value);
    event DepositInitiated(
        address l1Token, address indexed _from, address indexed _to, uint256 indexed _sequenceNumber, uint256 _amount
    );

    ////
    // Error declarations for easier debugging
    ///
    error InsufficientSubmissionCost(uint256, uint256);
    error InsufficientValue(uint256, uint256);
}
