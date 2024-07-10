// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";
import { IInbox } from "@arbitrum/nitro-contracts/src/bridge/IInbox.sol";
import { InboxMock } from "@arbitrum/tokenbridge/test/InboxMock.sol";
import { L2CustomGateway } from "@arbitrum/tokenbridge/arbitrum/gateway/L2CustomGateway.sol";

import { L1XERC20BaseGatewayTest } from "test/L1XERC20BaseGatewayTest.t.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

import { AttackerAdapter } from "test/mocks/AttackerAdapter.sol";

contract L1XERC20GatewayTest is L1XERC20BaseGatewayTest {
    function setUp() public override {
        l1GatewayRouter = makeAddr("l1GatewayRouter");
        l1Inbox = address(new InboxMock());

        super.setUp();
    }

    function registerAdapter(address _adapter) internal {
        address[] memory l1Addresses = new address[](1);
        l1Addresses[0] = address(_adapter);
        address[] memory l2Addresses = new address[](1);
        l2Addresses[0] = makeAddr("l2Token");

        deal(_owner, 2);

        vm.prank(_owner);
        l1Gateway.forceRegisterTokenToL2{ value: 2 }(l1Addresses, l2Addresses, 1, 1, 1);
    }

    function test_AddressIsAdapter() public view {
        assertEq(l1Gateway.addressIsAdapter(address(xerc20)), false);
        assertEq(l1Gateway.addressIsAdapter(address(adapter)), true);
    }

    function test_forceRegisterTokenToL2_onlyOwner() public {
        address[] memory l1Addresses = new address[](1);
        l1Addresses[0] = address(adapter);
        address[] memory l2Addresses = new address[](1);
        l2Addresses[0] = makeAddr("l2Token");

        address nonOwner = makeAddr("non_owner");
        deal(nonOwner, 2);

        vm.prank(nonOwner);
        vm.expectRevert("ONLY_OWNER");
        l1Gateway.forceRegisterTokenToL2{ value: 2 }(l1Addresses, l2Addresses, 1, 1, 1);
    }

    function test_forceRegisterTokenToL2() public {
        address[] memory l1Addresses = new address[](1);
        l1Addresses[0] = address(adapter);
        address[] memory l2Addresses = new address[](1);
        l2Addresses[0] = makeAddr("l2Token");

        bytes memory _data =
            abi.encodeWithSelector(L2CustomGateway.registerTokenFromL1.selector, l1Addresses, l2Addresses);

        vm.expectEmit(true, true, true, true, l1Inbox);
        emit InboxRetryableTicket(address(l1Gateway), address(l1Gateway.counterpartGateway()), 0, 1, _data);

        deal(_owner, 2);
        vm.prank(_owner);
        l1Gateway.forceRegisterTokenToL2{ value: 2 }(l1Addresses, l2Addresses, 1, 1, 1);
    }

    function test_FinalizeInboundTransfer() public {
        registerAdapter(address(adapter));

        InboxMock(address(l1Inbox)).setL2ToL1Sender(l1Gateway.counterpartGateway());

        uint256 exitNum = 7;
        bytes memory callHookData = "";
        bytes memory data = abi.encode(exitNum, callHookData);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(address(0), _dest, amountToBridge);

        vm.expectEmit(true, true, true, true, address(l1Gateway));
        emit WithdrawalFinalized(address(adapter), _user, _dest, exitNum, amountToBridge);

        uint256 balanceBefore = xerc20.balanceOf(_dest);

        vm.prank(address(IInbox(l1Gateway.inbox()).bridge()));
        l1Gateway.finalizeInboundTransfer(address(adapter), _user, _dest, amountToBridge, data);

        assertEq(xerc20.balanceOf(_dest), balanceBefore + amountToBridge);
    }

    function test_inboundEscrowTransfer_NotRegisteredToken() public {
        InboxMock(address(l1Inbox)).setL2ToL1Sender(l1Gateway.counterpartGateway());

        uint256 exitNum = 7;
        bytes memory callHookData = "";
        bytes memory data = abi.encode(exitNum, callHookData);

        vm.prank(address(IInbox(l1Gateway.inbox()).bridge()));
        vm.expectRevert(L1XERC20Gateway.NotRegisteredToken.selector);
        l1Gateway.finalizeInboundTransfer(address(adapter), _user, _dest, amountToBridge, data);
    }

    function test_inboundEscrowTransfer_uses_registered_adapterToToken() public {
        address attacker = makeAddr("attacker");
        XERC20 fakeXerc20 = new XERC20("FAKE", "FAKE", attacker);

        vm.prank(attacker);
        fakeXerc20.setLimits(address(l1Gateway), 420 ether, 69 ether);

        AttackerAdapter attackerAdapter = new AttackerAdapter(address(fakeXerc20), address(l1Gateway), attacker);

        registerAdapter(address(attackerAdapter));

        vm.prank(attacker);
        attackerAdapter.setXERC20(address(xerc20));

        InboxMock(address(l1Inbox)).setL2ToL1Sender(l1Gateway.counterpartGateway());

        uint256 exitNum = 7;
        bytes memory callHookData = "";
        bytes memory data = abi.encode(exitNum, callHookData);

        vm.expectEmit(true, true, true, true, address(fakeXerc20));
        emit Transfer(address(0), attacker, amountToBridge);

        vm.expectEmit(true, true, true, true, address(l1Gateway));
        emit WithdrawalFinalized(address(attackerAdapter), attacker, attacker, exitNum, amountToBridge);

        uint256 balanceBefore = xerc20.balanceOf(attacker);
        uint256 balanceFakeBefore = fakeXerc20.balanceOf(attacker);

        vm.prank(address(IInbox(l1Gateway.inbox()).bridge()));
        l1Gateway.finalizeInboundTransfer(address(attackerAdapter), attacker, attacker, amountToBridge, data);

        assertEq(fakeXerc20.balanceOf(attacker), balanceFakeBefore + amountToBridge);
        assertEq(xerc20.balanceOf(attacker), balanceBefore);
    }

    ////
    // Event declarations for assertions
    ////
    event WithdrawalFinalized(
        address l1Token, address indexed _from, address indexed _to, uint256 indexed _exitNum, uint256 _amount
    );

    event InboxRetryableTicket(address from, address to, uint256 value, uint256 maxGas, bytes data);
}
