// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { console2 } from "forge-std/console2.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";

import { XERC20BaseAdapterTest } from "test/XERC20BaseAdapterTest.t.sol";

contract L1XERC20AdapterTest is XERC20BaseAdapterTest {
    function test_IsArbitrumEnabled() public view {
        assertEq(L1XERC20Adapter(_adapter).isArbitrumEnabled(), uint8(0xb1));
    }

    function _createAdapter() internal override {
        _adapter = address(new L1XERC20Adapter(address(xerc20), makeAddr("gateway")));
    }
}
