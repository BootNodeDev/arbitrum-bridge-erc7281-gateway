// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";

import { XERC20BaseAdapter } from "src/XERC20BaseAdapter.sol";

abstract contract XERC20BaseAdapterTest is Test {
    XERC20 internal xerc20;

    address internal _owner = makeAddr("owner");
    address internal _minter = makeAddr("minter");
    address internal _user = makeAddr("user");

    address internal _adapter;
    XERC20BaseAdapter internal adapter;

    function setUp() public virtual {
        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);

        _createAdapter();
        adapter = XERC20BaseAdapter(_adapter);

        vm.prank(_owner);
        xerc20.setLimits(_minter, 42 ether, 0);
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

    ////
    // Helpers
    ////
    function _createAdapter() internal virtual {
        assert(false);
    }
}
