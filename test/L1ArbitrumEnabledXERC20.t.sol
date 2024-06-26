// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/Test.sol";

// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { L1ArbitrumEnabledXERC20 } from "src/L1ArbitrumEnabledXERC20.sol";
import { L1ArbitrumEnabled } from "src/libraries/L1ArbitrumEnabled.sol";

import { GatewayMock } from "test/mocks/GatewayMock.sol";
import { RouterMock } from "test/mocks/RouterMock.sol";

contract L1XERC20AdapterTest is Test {
    GatewayMock internal gateway;
    L1ArbitrumEnabledXERC20 internal arbEnabledToken;
    address internal _owner = makeAddr("owner");

    function setUp() public {
        gateway = new GatewayMock();

        arbEnabledToken = new L1ArbitrumEnabledXERC20("ArbitrumEnabledToken", "AET", _owner, address(gateway));
    }

    function test_IsArbitrumEnabled() public view {
        assertEq(arbEnabledToken.isArbitrumEnabled(), uint8(0xb1));
    }

    function test_registerTokenOnL2_WrongValue(uint256 valueForGateway, uint256 valueForRouter) public {
        // bound to avoid overflow or underflow
        valueForGateway = bound(valueForGateway, 1, 1e36);
        valueForRouter = bound(valueForRouter, 1, 1e36);

        deal(_owner, valueForGateway + valueForRouter + 1);

        vm.prank(_owner);
        vm.expectRevert(L1ArbitrumEnabled.WrongValue.selector);
        arbEnabledToken.registerTokenOnL2{ value: valueForGateway + valueForRouter - 1 }(
            makeAddr("l2Token"), 0, 0, 0, 0, 0, valueForGateway, valueForRouter, makeAddr("creditBack")
        );

        vm.prank(_owner);
        vm.expectRevert(L1ArbitrumEnabled.WrongValue.selector);
        arbEnabledToken.registerTokenOnL2{ value: valueForGateway + valueForRouter + 1 }(
            makeAddr("l2Token"), 0, 0, 0, 0, 0, valueForGateway, valueForRouter, makeAddr("creditBack")
        );
    }

    function test_registerTokenOnL2_works(uint256 valueForGateway, uint256 valueForRouter) public {
        // bound to avoid overflow or underflow
        valueForGateway = bound(valueForGateway, 1, 1e36);
        valueForRouter = bound(valueForRouter, 1, 1e36);

        deal(_owner, valueForGateway + valueForRouter);

        address router = gateway.router();

        vm.prank(_owner);
        vm.expectCall(address(gateway), valueForGateway, abi.encodePacked(GatewayMock.registerTokenToL2.selector));
        vm.expectCall(address(gateway), abi.encodePacked(GatewayMock.router.selector));
        vm.expectCall(router, valueForRouter, abi.encodePacked(RouterMock.setGateway.selector));
        arbEnabledToken.registerTokenOnL2{ value: valueForGateway + valueForRouter }(
            makeAddr("l2Token"), 0, 0, 0, 0, 0, valueForGateway, valueForRouter, makeAddr("creditBack")
        );
    }
}
