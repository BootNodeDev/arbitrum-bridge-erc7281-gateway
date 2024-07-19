// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";
// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { IInbox } from "@arbitrum/nitro-contracts/src/bridge/IInbox.sol";
import { InboxMock } from "@arbitrum/tokenbridge/test/InboxMock.sol";

import { L1GatewayRouter } from "@arbitrum/tokenbridge/ethereum/gateway/L1GatewayRouter.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";
import { XERC20Lockbox } from "xerc20/contracts/XERC20Lockbox.sol";

import { L1LockboxGateway } from "src/L1LockboxGateway.sol";

contract L1LockboxGatewayForkingTest is Test {
    uint256 internal mainnetFork;

    XERC20Lockbox internal lockbox = XERC20Lockbox(payable(0xC8140dA31E6bCa19b287cC35531c2212763C2059));
    IERC20 internal erc20;
    XERC20 internal xerc20;
    address internal l2TokenAddress;

    address internal l1Inbox = 0x4Dbd4fc535Ac27206064B68FfCf827b0A60BAB3f;
    address internal l1GatewayRouter = 0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef;
    L1LockboxGateway internal l1Gateway;

    address internal _owner = makeAddr("owner");
    address internal _user = makeAddr("user");
    address internal _dest = makeAddr("dest");

    uint256 internal amountToBridge = 25;
    uint256 internal maxSubmissionCost = 20;
    uint256 internal maxGas = 1_000_000_000;
    uint256 internal gasPriceBid = 1_000_000_000;

    function setUp() public {
        mainnetFork = vm.createSelectFork("mainnet", 20_340_311);
        // WARNING: tests will only pass when setting block.basefee to 0
        // or when running with --gas-report, which makes it seem like there's
        // a bug in forge when using this flag.
        // This is safe since block.basefee is only used by the Inbox to check
        // if enough funds were submitted in order to send/redeem the
        // cross-chain message.
        vm.fee(0);

        l2TokenAddress = address(lockbox.XERC20());

        vm.label(l1Inbox, "l1Inbox");
        vm.label(l1GatewayRouter, "l1GatewayRouter");
        l1Gateway = new L1LockboxGateway(payable(lockbox), l1GatewayRouter, l1Inbox, _owner);
        vm.label(address(l1Gateway), "l1Gateway");

        vm.label(address(lockbox), "lockbox");
        erc20 = lockbox.ERC20();
        vm.label(address(erc20), "erc20");
        xerc20 = XERC20(address(lockbox.XERC20()));
        vm.label(address(xerc20), "xerc20");

        vm.prank(xerc20.owner());
        xerc20.setLimits(address(l1Gateway), 420 ether, 69 ether);

        _registerToken();
    }

    function test_RegisterTokenOnL2() public view {
        L1GatewayRouter router = L1GatewayRouter(l1GatewayRouter);
        assertEq(router.getGateway(address(erc20)), address(l1Gateway));
        assertEq(router.calculateL2TokenAddress(address(erc20)), l2TokenAddress);
    }

    function test_OutboundTransferCustomRefund() public {
        deal(address(erc20), _user, 10 ether);
        vm.prank(_user);
        erc20.approve(address(l1Gateway), amountToBridge);

        uint256 balanceBefore = erc20.balanceOf(_user);

        vm.expectEmit(true, true, true, true, address(erc20));
        emit Transfer(_user, address(l1Gateway), amountToBridge);

        vm.expectEmit(true, true, true, true, address(erc20));
        emit Transfer(address(l1Gateway), address(lockbox), amountToBridge);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(address(0), address(l1Gateway), amountToBridge);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(address(l1Gateway), address(0), amountToBridge);

        vm.expectEmit(true, true, true, true, address(l1Gateway));
        emit DepositInitiated(address(erc20), _user, _dest, 1_487_344, amountToBridge);

        L1GatewayRouter router = L1GatewayRouter(l1GatewayRouter);

        deal(_user, 10 ether);
        vm.prank(_user);
        router.outboundTransferCustomRefund{ value: 3 ether }(
            address(erc20), _dest, _dest, amountToBridge, maxGas, gasPriceBid, abi.encode(maxSubmissionCost, "")
        );

        assertEq(erc20.balanceOf(_user), balanceBefore - amountToBridge);
    }

    function test_FinalizeInboundTransfer() public {
        address l1InboxMock = address(new InboxMock());
        vm.etch(address(l1Inbox), l1InboxMock.code);
        InboxMock(address(l1Inbox)).setL2ToL1Sender(l1Gateway.counterpartGateway());

        uint256 exitNum = 7;
        bytes memory callHookData = "";
        bytes memory data = abi.encode(exitNum, callHookData);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(address(0), address(l1Gateway), amountToBridge);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(address(l1Gateway), address(0), amountToBridge);

        vm.expectEmit(true, true, true, true, address(erc20));
        emit Transfer(address(lockbox), _dest, amountToBridge);

        vm.expectEmit(true, true, true, true, address(l1Gateway));
        emit WithdrawalFinalized(address(erc20), _user, _dest, exitNum, amountToBridge);

        uint256 balanceBefore = erc20.balanceOf(_dest);

        vm.prank(address(IInbox(l1Gateway.inbox()).bridge()));
        l1Gateway.finalizeInboundTransfer(address(erc20), _user, _dest, amountToBridge, data);

        assertEq(erc20.balanceOf(_dest), balanceBefore + amountToBridge);
    }

    function test_RegisterTokenToL2_NotImplementedFunction(
        address _l2Address,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost,
        address _creditBackAddress
    )
        public
    {
        vm.expectRevert(L1LockboxGateway.NotImplementedFunction.selector);
        l1Gateway.registerTokenToL2(_l2Address, _maxGas, _gasPriceBid, _maxSubmissionCost);

        vm.expectRevert(L1LockboxGateway.NotImplementedFunction.selector);
        l1Gateway.registerTokenToL2(_l2Address, _maxGas, _gasPriceBid, _maxSubmissionCost, _creditBackAddress);
    }

    function test_ForceRegisterTokenToL2_NotImplementedFunction(
        address[] calldata _l1Addresses,
        address[] calldata _l2Addresses,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost
    )
        public
    {
        vm.expectRevert(L1LockboxGateway.NotImplementedFunction.selector);
        l1Gateway.forceRegisterTokenToL2(_l1Addresses, _l2Addresses, _maxGas, _gasPriceBid, _maxSubmissionCost);
    }

    ////
    // Helpers
    ////
    function _registerToken() internal {
        address[] memory l1Tokens = new address[](1);
        l1Tokens[0] = address(erc20);
        address[] memory l2Tokens = new address[](1);
        l2Tokens[0] = l2TokenAddress;
        address[] memory l1Gateways = new address[](1);
        l1Gateways[0] = address(l1Gateway);

        L1GatewayRouter router = L1GatewayRouter(l1GatewayRouter);
        deal(router.owner(), 100 ether);
        vm.prank(router.owner());
        router.setGateways{ value: 2 ether }(l1Tokens, l1Gateways, maxGas, gasPriceBid, maxSubmissionCost);
    }

    ////
    // Event declarations for assertions
    ////
    event Transfer(address indexed from, address indexed to, uint256 value);
    event DepositInitiated(
        address l1Token, address indexed _from, address indexed _to, uint256 indexed _sequenceNumber, uint256 _amount
    );
    event WithdrawalFinalized(
        address l1Token, address indexed _from, address indexed _to, uint256 indexed _exitNum, uint256 _amount
    );

    ////
    // Error declarations for easier debugging
    ///
    error InsufficientSubmissionCost(uint256, uint256);
    error InsufficientValue(uint256, uint256);
}
