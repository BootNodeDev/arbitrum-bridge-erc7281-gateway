// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { console2 } from "forge-std/console2.sol";

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L2XERC20Adapter } from "src/L2XERC20Adapter.sol";
import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";

import { XERC20BaseAdapterTest } from "test/XERC20BaseAdapterTest.t.sol";

contract L2XERC20AdapterTest is XERC20BaseAdapterTest {
    L2XERC20Adapter internal adapter;

    address internal _l1Token = makeAddr("l1Token");

    function setUp() public override {
        super.setUp();

        adapter = new L2XERC20Adapter(address(xerc20), makeAddr("gateway"), _l1Token);
    }

    function test_L1Address() public view {
        assertEq(adapter.l1Address(), _l1Token);
    }

    function test_GetXERC20() public view {
        assertEq(adapter.getXERC20(), address(xerc20));
    }

    function test_Name() public view {
        assertEq(adapter.name(), xerc20.name());
    }

    function test_Symbol() public view {
        assertEq(adapter.symbol(), xerc20.symbol());
    }

    function test_Decimals() public view {
        assertEq(adapter.decimals(), xerc20.decimals());
    }

    function test_TotalSupply() public {
        vm.prank(_minter);
        xerc20.mint(_user, 10 ether);

        assertEq(adapter.totalSupply(), 10 ether);
    }

    function test_BalanceOf() public {
        vm.prank(_minter);
        xerc20.mint(_user, 1 ether);

        assertEq(adapter.balanceOf(_user), xerc20.balanceOf(_user));
    }

    function test_SupportsInterface() public view {
        bytes4 iface = type(IERC165).interfaceId;
        assertEq(adapter.supportsInterface(iface), true, "Interface should be supported");

        iface = type(IXERC20Adapter).interfaceId;
        assertEq(adapter.supportsInterface(iface), true, "Interface should be supported");

        iface = bytes4(0);
        assertEq(adapter.supportsInterface(iface), false, "Interface shouldn't be supported");
    }
}
