// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1XERC20GatewayForkingTest } from "test/forking/L1XERC20Gateway.t.sol";

import { L1ArbitrumEnabledXERC20TestToken } from "test/L1ArbitrumEnabledXERC20TestToken.sol";

contract L1XERC20GatewayArbitrumCompatibleTokenTest is L1XERC20GatewayForkingTest {
    L1ArbitrumEnabledXERC20TestToken internal arbEnabledToken;

    function setUp() public override {
        super.setUp();
        bridgeable = address(arbEnabledToken);
    }

    function _createXERC20() internal override {
        arbEnabledToken = new L1ArbitrumEnabledXERC20TestToken(address(l1Gateway), _owner);
        xerc20 = XERC20(address(arbEnabledToken));
    }
}
