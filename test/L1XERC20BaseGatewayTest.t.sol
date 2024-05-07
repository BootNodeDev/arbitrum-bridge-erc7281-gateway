// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

abstract contract L1XERC20BaseGatewayTest is Test {
    XERC20 internal xerc20;
    L1XERC20Adapter internal adapter;
    L1XERC20Gateway internal l1Gateway;
    address internal l1GatewayRouter;

    address internal l1Inbox;

    address internal _owner = makeAddr("owner");
    address internal _user = makeAddr("user");
    address internal _dest = makeAddr("dest");

    uint256 internal amountToBridge = 25;

    function _setUp() internal {
        assert(l1GatewayRouter != address(0));
        vm.label(l1GatewayRouter, "l1GatewayRouter");
        assert(l1Inbox != address(0));
        vm.label(l1Inbox, "l1Inbox");

        l1Gateway = new L1XERC20Gateway(l1GatewayRouter, l1Inbox);

        xerc20 = new XERC20("NonArbitrumEnabled", "NON", _owner);
        vm.prank(_owner);
        xerc20.setLimits(address(l1Gateway), 420 ether, 69 ether);

        vm.prank(_owner);
        adapter = new L1XERC20Adapter(address(xerc20), address(l1Gateway));
    }

    ////
    // Event declarations for assertions
    ////
    event Transfer(address indexed from, address indexed to, uint256 value);
}
