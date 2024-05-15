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
    function setUp() public virtual override {
        vm.label(l2GatewayRouter, "l2GatewayRouter");

        _createXERC20();
        bridgeable = address(xerc20);

        l2Gateway = new L2LockboxGateway(l1Counterpart, l2GatewayRouter, l1Token, address(xerc20));

        vm.prank(_owner);
        xerc20.setLimits(address(l2Gateway), 420 ether, 69 ether);
    }

    function test_RegisterTokenFromL1_NotImplementedFunction(
        address[] calldata _l1Tokens,
        address[] calldata _l2Tokens
    )
        public
    {
        vm.expectRevert(L2LockboxGateway.NotImplementedFunction.selector);
        l2Gateway.registerTokenFromL1(_l1Tokens, _l2Tokens);
    }
}
