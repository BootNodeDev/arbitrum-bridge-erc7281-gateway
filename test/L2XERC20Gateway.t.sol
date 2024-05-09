// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";
// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { ArbSysMock } from "@arbitrum/tokenbridge/test/ArbSysMock.sol";
import { AddressAliasHelper } from "@arbitrum/tokenbridge/libraries/AddressAliasHelper.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L2XERC20Adapter } from "src/L2XERC20Adapter.sol";

import { L2XERC20Gateway } from "src/L2XERC20Gateway.sol";

contract L2XERC20GatewayTest is Test {
    ArbSysMock public arbSysMock = new ArbSysMock();

    XERC20 internal xerc20;
    L2XERC20Adapter internal adapter;

    address internal _owner = makeAddr("owner");
    address internal _user = makeAddr("user");
    address internal _dest = makeAddr("dest");

    uint256 internal amountToBridge = 25;

    address internal l2GatewayRouter = 0x5288c571Fd7aD117beA99bF60FE0846C4E84F933;
    L2XERC20Gateway internal l2Gateway;

    address internal l1Counterpart = makeAddr("l1Counterpart");
    address internal l1Token = makeAddr("l1Token");

    address internal bridgeable;

    function setUp() public virtual {
        vm.label(l2GatewayRouter, "l2GatewayRouter");

        l2Gateway = new L2XERC20Gateway(l1Counterpart, l2GatewayRouter);

        _createXERC20();

        vm.prank(_owner);
        adapter = new L2XERC20Adapter(address(xerc20), address(l2Gateway), l1Token);
        _setBridgeable();

        vm.prank(_owner);
        xerc20.setLimits(address(l2Gateway), 420 ether, 69 ether);

        _registerToken();
    }

    function test_OutboundTransfer() public {
        deal(address(xerc20), _user, 10 ether);

        vm.prank(_user);
        xerc20.approve(address(l2Gateway), amountToBridge);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(_user, address(0), amountToBridge);

        // withdrawal params
        bytes memory data = "";

        uint256 expectedId = 0;
        bytes memory expectedData = l2Gateway.getOutboundCalldata(l1Token, _user, _dest, amountToBridge, data);
        vm.expectEmit(true, true, true, true, address(l2Gateway));
        emit TxToL1(_user, l1Counterpart, expectedId, expectedData);

        vm.expectEmit(true, true, true, true, address(l2Gateway));
        emit WithdrawalInitiated(l1Token, _user, _dest, expectedId, 0, amountToBridge);

        uint256 balanceBefore = xerc20.balanceOf(_user);

        vm.etch(0x0000000000000000000000000000000000000064, address(arbSysMock).code);
        vm.prank(_user);
        l2Gateway.outboundTransfer(l1Token, _dest, amountToBridge, 0, 0, data);

        assertEq(xerc20.balanceOf(_user), balanceBefore - amountToBridge);
    }

    function test_FinalizeInboundTransfer() public {
        bytes memory gatewayData = "";
        bytes memory callHookData = "";
        bytes memory data = abi.encode(gatewayData, callHookData);

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(address(0), _dest, amountToBridge);

        vm.expectEmit(true, true, true, true, address(l2Gateway));
        emit DepositFinalized(l1Token, _user, _dest, amountToBridge);

        uint256 balanceBefore = xerc20.balanceOf(_dest);

        vm.prank(AddressAliasHelper.applyL1ToL2Alias(l1Counterpart));
        l2Gateway.finalizeInboundTransfer(l1Token, _user, _dest, amountToBridge, data);

        assertEq(xerc20.balanceOf(_dest), balanceBefore + amountToBridge);
    }

    ////
    // Helpers
    ////

    function _createXERC20() internal virtual {
        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);
    }

    function _setBridgeable() internal virtual {
        bridgeable = address(adapter);
    }

    //// shamelessly stolen from @arbitrum
    function _registerToken() internal virtual returns (address) {
        address[] memory l1Tokens = new address[](1);
        l1Tokens[0] = l1Token;

        address[] memory l2Tokens = new address[](1);
        l2Tokens[0] = bridgeable;

        vm.prank(AddressAliasHelper.applyL1ToL2Alias(l1Counterpart));
        l2Gateway.registerTokenFromL1(l1Tokens, l2Tokens);

        return l2Tokens[0];
    }

    ////
    // Event declarations for assertions
    ////
    event Transfer(address indexed from, address indexed to, uint256 value);
    event WithdrawalInitiated(
        address l1Token,
        address indexed _from,
        address indexed _receiver,
        uint256 indexed _l2ToL1Id,
        uint256 _exitNum,
        uint256 _amount
    );
    event DepositFinalized(address indexed l1Token, address indexed _from, address indexed _receiver, uint256 _amount);
    event TxToL1(address indexed _from, address indexed _receiver, uint256 indexed _id, bytes _data);
}
