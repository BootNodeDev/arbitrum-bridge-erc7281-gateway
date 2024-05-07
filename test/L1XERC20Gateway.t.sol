// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { IInbox } from "@arbitrum/nitro-contracts/src/bridge/IInbox.sol";
import { InboxMock } from "@arbitrum/tokenbridge/test/InboxMock.sol";

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

import { L1XERC20BaseGatewayTest } from "test/L1XERC20BaseGatewayTest.t.sol";

contract L1XERC20GatewayTest is L1XERC20BaseGatewayTest {
    function setUp() public {
        l1GatewayRouter = makeAddr("l1GatewayRouter");
        l1Inbox = address(new InboxMock());

        _setUp();
    }

    function test_AddressIsAdapter() public view {
        assertEq(l1Gateway.addressIsAdapter(address(xerc20)), false);
        assertEq(l1Gateway.addressIsAdapter(address(adapter)), true);
    }

    function test_FinalizeInboundTransfer() public {
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

    ////
    // Event declarations for assertions
    ////
    event WithdrawalFinalized(
        address l1Token, address indexed _from, address indexed _to, uint256 indexed _exitNum, uint256 _amount
    );
}
