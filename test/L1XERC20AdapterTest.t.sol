// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";
import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";

contract L1XERC20AdapterTest is Test {
    XERC20 internal xerc20;
    L1XERC20Adapter internal adapter;

    address internal _owner = address(0x1);
    address internal _minter = address(0x2);
    address internal _user = address(0x3);

    function setUp() public {
        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);
        adapter = new L1XERC20Adapter(address(xerc20), makeAddr("gateway"));

        vm.prank(_owner);
        xerc20.setLimits(_minter, 42 ether, 0);
    }

    function test_IsArbitrumEnabled() public view {
        assertEq(adapter.isArbitrumEnabled(), uint8(0xb1));
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
