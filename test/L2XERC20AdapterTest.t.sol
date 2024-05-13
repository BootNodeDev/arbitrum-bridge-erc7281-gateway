// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { console2 } from "forge-std/console2.sol";

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L2XERC20Adapter } from "src/L2XERC20Adapter.sol";
import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";

import { XERC20BaseAdapterTest } from "test/XERC20BaseAdapterTest.t.sol";

contract L2XERC20AdapterTest is XERC20BaseAdapterTest {
    address internal _l1Token = makeAddr("l1Token");

    function test_L1Address() public view {
        assertEq(L2XERC20Adapter(_adapter).l1Address(), _l1Token);
    }

    function _createAdapter() internal override {
        _adapter = address(new L2XERC20Adapter(address(xerc20), _l1Token, _owner));
    }
}
