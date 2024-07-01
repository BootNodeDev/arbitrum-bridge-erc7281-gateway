// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1GatewayRouter } from "@arbitrum/tokenbridge/ethereum/gateway/L1GatewayRouter.sol";
import { ICustomToken } from "@arbitrum/tokenbridge/ethereum/ICustomToken.sol";
import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

import { L1XERC20BaseGatewayTest } from "test/L1XERC20BaseGatewayTest.t.sol";
import {AttackerAdapter} from "test/mocks/AttackerAdapter.sol";

contract L1XERC20GatewayForkingTest is L1XERC20BaseGatewayTest {
    uint256 internal mainnetFork;

    address internal l2TokenAddress = makeAddr("l2TokenAddress");
    address internal _attacker = makeAddr("attacker");

    uint256 public maxSubmissionCost = 20;
    uint256 public maxGas = 1_000_000_000;
    uint256 public gasPriceBid = 1_000_000_000;
    uint256 public nativeTokenTotalFee = gasPriceBid * maxGas;
    uint256 public retryableCost = maxSubmissionCost + nativeTokenTotalFee;

    address internal bridgeable;

    function setUp() public virtual override {
        mainnetFork = vm.createSelectFork("mainnet", 19_690_420);
        // WARNING: tests will only pass when setting block.basefee to 0
        // or when running with --gas-report, which makes it seem like there's
        // a bug in forge when using this flag.
        // This is safe since block.basefee is only used by the Inbox to check
        // if enough funds were submitted in order to send/redeem the
        // cross-chain message.
        vm.fee(0);

        l1GatewayRouter = 0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef;
        l1Inbox = 0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f;

        deal(_owner, 100 ether + retryableCost * 2);
        deal(_attacker, 100 ether);

        super.setUp();
        bridgeable = address(adapter);
    }

    function test_RegisterTokenOnL2() public {
        vm.prank(_owner);
        ICustomToken(bridgeable).registerTokenOnL2{ value: retryableCost * 2 }(
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
        assertEq(router.getGateway(bridgeable), address(l1Gateway));
        assertEq(router.calculateL2TokenAddress(bridgeable), l2TokenAddress);
    }

    function test_RegisterTokenToL2_AlreadyRegisteredL1Token() public {
        test_RegisterTokenOnL2();

        vm.prank(_attacker);
        L1XERC20Adapter fakeAdapter = new L1XERC20Adapter(address(xerc20), address(l1Gateway), _attacker);

        vm.expectRevert(L1XERC20Gateway.AlreadyRegisteredL1Token.selector);
        vm.prank(_attacker);
        ICustomToken(address(fakeAdapter)).registerTokenOnL2{ value: retryableCost * 2 }(
            makeAddr("fakeL2TokenAddress"),
            maxSubmissionCost,
            maxSubmissionCost,
            maxGas,
            maxGas,
            gasPriceBid,
            retryableCost,
            retryableCost,
            _attacker
        );
    }

    function test_RegisterTokenToL2_AlreadyRegisteredL2Token() public {
        test_RegisterTokenOnL2();

        vm.prank(_attacker);
        XERC20 fakeXerc20 = new XERC20("Fake", "FAKE", _attacker);

        vm.prank(_attacker);
        L1XERC20Adapter fakeAdapter = new L1XERC20Adapter(address(fakeXerc20), address(l1Gateway), _attacker);

        vm.expectRevert(L1XERC20Gateway.AlreadyRegisteredL2Token.selector);
        vm.prank(_attacker);
        ICustomToken(address(fakeAdapter)).registerTokenOnL2{ value: retryableCost * 2 }(
            l2TokenAddress,
            maxSubmissionCost,
            maxSubmissionCost,
            maxGas,
            maxGas,
            gasPriceBid,
            retryableCost,
            retryableCost,
            _attacker
        );
    }

    function test_OutboundTransferCustomRefund_uses_registered_adapterToToken() public {
        address attacker = makeAddr("attacker");
        XERC20 fakeXerc20 = new XERC20("FAKE", "FAKE", attacker);

        vm.prank(attacker);
        fakeXerc20.setLimits(address(l1Gateway), 420 ether, 69 ether);

        AttackerAdapter attackerAdapter = new AttackerAdapter(address(fakeXerc20), address(l1Gateway), attacker);

        vm.prank(attacker);
        attackerAdapter.registerTokenOnL2{ value: retryableCost * 2 }(
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

        vm.prank(attacker);
        attackerAdapter.setXERC20(address(xerc20));

        deal(address(xerc20), attacker, 10 ether);
        deal(address(fakeXerc20), attacker, 10 ether);
        vm.prank(attacker);
        fakeXerc20.approve(address(l1Gateway), amountToBridge);

        L1GatewayRouter router = L1GatewayRouter(l1GatewayRouter);

        vm.expectEmit(true, true, true, true, address(fakeXerc20));
        emit Transfer(attacker, address(0), amountToBridge);

        vm.expectEmit(true, true, true, true, address(l1Gateway));
        emit DepositInitiated(address(attackerAdapter), attacker, attacker, 1_487_345, amountToBridge);

        uint256 balanceBefore = xerc20.balanceOf(attacker);
        uint256 balanceFakeBefore = fakeXerc20.balanceOf(attacker);

        deal(attacker, 10 ether);
        vm.prank(attacker);
        router.outboundTransferCustomRefund{ value: 3 ether }(
            address(attackerAdapter), attacker, _attacker, amountToBridge, maxGas, gasPriceBid, abi.encode(maxSubmissionCost, "")
        );

        assertEq(fakeXerc20.balanceOf(attacker), balanceFakeBefore - amountToBridge);
        assertEq(xerc20.balanceOf(attacker), balanceBefore);
    }

    function test_OutboundTransferCustomRefund() public {
        vm.prank(_owner);
        ICustomToken(bridgeable).registerTokenOnL2{ value: retryableCost * 2 }(
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

        deal(address(xerc20), _user, 10 ether);
        vm.prank(_user);
        xerc20.approve(address(l1Gateway), amountToBridge);

        L1GatewayRouter router = L1GatewayRouter(l1GatewayRouter);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(_user, address(0), amountToBridge);

        vm.expectEmit(true, true, true, true, address(l1Gateway));
        emit DepositInitiated(bridgeable, _user, _dest, 1_487_345, amountToBridge);

        uint256 balanceBefore = xerc20.balanceOf(_user);

        deal(_user, 10 ether);
        vm.prank(_user);
        router.outboundTransferCustomRefund{ value: 3 ether }(
            bridgeable, _dest, _dest, amountToBridge, maxGas, gasPriceBid, abi.encode(maxSubmissionCost, "")
        );

        assertEq(xerc20.balanceOf(_user), balanceBefore - amountToBridge);
    }

    ////
    // Event declarations for assertions
    ////
    event DepositInitiated(
        address l1Token, address indexed _from, address indexed _to, uint256 indexed _sequenceNumber, uint256 _amount
    );

    ////
    // Error declarations for easier debugging
    ///
    error InsufficientSubmissionCost(uint256, uint256);
    error InsufficientValue(uint256, uint256);
}
