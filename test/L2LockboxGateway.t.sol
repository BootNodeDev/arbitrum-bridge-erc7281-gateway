// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";
// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { ArbSysMock } from "@arbitrum/tokenbridge/test/ArbSysMock.sol";
import { AddressAliasHelper } from "@arbitrum/tokenbridge/libraries/AddressAliasHelper.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L2LockboxGateway } from "src/L2LockboxGateway.sol";
import { L2XERC20GatewayTest } from "test/L2XERC20Gateway.t.sol";

contract L2LockboxGatewayTest is L2XERC20GatewayTest {

    // XERC20 internal xerc20;

    // address internal _owner = makeAddr("owner");
    // address internal _user = makeAddr("user");
    // address internal _dest = makeAddr("dest");

    // uint256 internal amountToBridge = 25;

    // address internal l2GatewayRouter = 0x5288c571Fd7aD117beA99bF60FE0846C4E84F933;
    // L2XERC20Gateway internal l2Gateway;

    // address internal l1Counterpart = makeAddr("l1Counterpart");
    // address internal l1Token = makeAddr("l1Token");

    // address internal bridgeable;

    function setUp() public virtual override {
        vm.label(l2GatewayRouter, "l2GatewayRouter");

        _createXERC20();
        bridgeable = address(xerc20);

        l2Gateway = new L2LockboxGateway(l1Counterpart, l2GatewayRouter, l1Token, address(xerc20));

        vm.prank(_owner);
        xerc20.setLimits(address(l2Gateway), 420 ether, 69 ether);
    }

    function test_RegisterTokenFromL1_NotImplementedFunction() public {
        address[] memory l1Tokens = new address[](1);
        l1Tokens[0] = l1Token;

        address[] memory l2Tokens = new address[](1);
        l2Tokens[0] = bridgeable;

        vm.expectRevert(L2LockboxGateway.NotImplementedFunction.selector);
        l2Gateway.registerTokenFromL1(l1Tokens, l2Tokens);

    }
}
