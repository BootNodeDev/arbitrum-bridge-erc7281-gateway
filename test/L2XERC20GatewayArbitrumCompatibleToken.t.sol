// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

// solhint-disable-next-line
import { console2 } from "forge-std/console2.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L2XERC20GatewayTest } from "test/L2XERC20Gateway.t.sol";

import { L2ArbitrumEnabledXERC20TestToken } from "test/L2ArbitrumEnabledXERC20TestToken.sol";

contract L2XERC20GatewayArbitrumCompatibleTokenTest is L2XERC20GatewayTest {
    L2ArbitrumEnabledXERC20TestToken internal arbEnabledToken;

    function _createXERC20() internal override {
        arbEnabledToken = new L2ArbitrumEnabledXERC20TestToken(l1Token, _owner);
        xerc20 = XERC20(address(arbEnabledToken));
    }

    function _setBridgeable() internal override {
        bridgeable = address(xerc20);
    }
}
