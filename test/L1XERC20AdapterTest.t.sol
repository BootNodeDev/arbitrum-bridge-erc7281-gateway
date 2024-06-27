// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";

import { XERC20BaseAdapterTest } from "test/XERC20BaseAdapterTest.t.sol";

contract L1XERC20AdapterTest is XERC20BaseAdapterTest {
    function test_IsArbitrumEnabled() public view {
        assertEq(L1XERC20Adapter(_adapter).isArbitrumEnabled(), uint8(0xb1));
    }

    function test_registerTokenOnL2_OnlyOwner() public {
        address caller = makeAddr("someOther");
        deal(caller, 2);

        vm.prank(caller);
        vm.expectRevert("Ownable: caller is not the owner");
        L1XERC20Adapter(_adapter).registerTokenOnL2{ value: 2}(
            makeAddr("l2Token"), 0, 0, 0, 0, 0, 1, 1, makeAddr("creditBack")
        );
    }

    function _createAdapter() internal override {
        _adapter = address(new L1XERC20Adapter(address(xerc20), makeAddr("gateway"), _owner));
    }
}
