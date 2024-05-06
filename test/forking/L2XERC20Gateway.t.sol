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
    uint256 internal arbitrumFork;

    ArbSysMock public arbSysMock = new ArbSysMock();

    XERC20 internal xerc20;
    L2XERC20Adapter internal adapter;

    address internal _owner = makeAddr("owner");
    address internal _minter = makeAddr("minter");
    address internal _user = makeAddr("user");

    address internal l2GatewayRouter = 0x5288c571Fd7aD117beA99bF60FE0846C4E84F933;
    L2XERC20Gateway internal l2Gateway;

    address internal l1Counterpart = makeAddr("l1Counterpart");
    address internal l1Token = makeAddr("l1Token");

    function setUp() public {
        vm.label(l2GatewayRouter, "l2GatewayRouter");

        arbitrumFork = vm.createFork("arbitrum", 202_675_145);

        l2Gateway = new L2XERC20Gateway(l1Counterpart, l2GatewayRouter);

        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);

        vm.prank(_owner);
        adapter = new L2XERC20Adapter(address(xerc20), address(l2Gateway), l1Token, _owner);

        vm.prank(_owner);
        xerc20.setLimits(_minter, 42 ether, 0);

        vm.prank(_minter);
        xerc20.mint(_user, 10 ether);
    }

    function test_OutboundTransfer() public {
        _registerToken();

        vm.prank(_owner);
        xerc20.setLimits(address(l2Gateway), 0, 42 ether);

        vm.prank(_user);
        xerc20.approve(address(l2Gateway), 1 ether);

        address dest = makeAddr("dest");

        vm.expectEmit(true, true, true, true, address(xerc20));
        emit Transfer(_user, address(0), 1 ether);

        // withdrawal params
        bytes memory data = new bytes(0);

        uint256 expectedId = 0;
        bytes memory expectedData = l2Gateway.getOutboundCalldata(l1Token, _user, dest, 1 ether, data);
        vm.expectEmit(true, true, true, true);
        emit TxToL1(_user, l1Counterpart, expectedId, expectedData);

        vm.expectEmit(true, true, true, true, address(l2Gateway));
        emit WithdrawalInitiated(l1Token, _user, dest, expectedId, 0, 1 ether);

        vm.etch(0x0000000000000000000000000000000000000064, address(arbSysMock).code);
        vm.prank(_user);
        l2Gateway.outboundTransfer(l1Token, dest, 1 ether, 0, 0, bytes(""));

        assertEq(adapter.balanceOf(_user), xerc20.balanceOf(_user));
        assertEq(xerc20.balanceOf(_user), 9 ether);
    }

    ////
    // Internal helper functions (shamelessly stolen from @arbitrum)
    ////
    function _registerToken() internal virtual returns (address) {
        address[] memory l1Tokens = new address[](1);
        l1Tokens[0] = l1Token;

        address[] memory l2Tokens = new address[](1);
        l2Tokens[0] = address(adapter);

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
    event TxToL1(address indexed _from, address indexed _receiver, uint256 indexed _id, bytes _data);
}
