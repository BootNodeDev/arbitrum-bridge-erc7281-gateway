// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

abstract contract XERC20BaseAdapterTest is Test {
    XERC20 internal xerc20;

    address internal _owner = makeAddr("owner");
    address internal _minter = makeAddr("minter");
    address internal _user = makeAddr("user");

    function setUp() public virtual {
        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);

        vm.prank(_owner);
        xerc20.setLimits(_minter, 42 ether, 0);
    }
}
