// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

contract L1XERC20GatewayTest is Test {
    XERC20 internal xerc20;
    L1XERC20Adapter internal adapter;
    L1XERC20Gateway internal gateway;

    address internal _owner = makeAddr("owner");

    function setUp() public {
        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);
        gateway = new L1XERC20Gateway(makeAddr("router"), makeAddr("inbox"));
        adapter = new L1XERC20Adapter(address(xerc20), address(gateway));
    }

    function test_AddressIsAdapter() public view {
        assertEq(gateway.addressIsAdapter(address(xerc20)), false);
        assertEq(gateway.addressIsAdapter(address(adapter)), true);
    }
}
