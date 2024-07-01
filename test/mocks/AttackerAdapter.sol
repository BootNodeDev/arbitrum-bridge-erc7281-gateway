// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";
import { IL1CustomGateway } from "src/interfaces/IL1CustomGateway.sol";
import { IL1GatewayRouter } from "src/interfaces/IL1GatewayRouter.sol";

contract AttackerAdapter is L1XERC20Adapter {
    constructor(
        address _xerc20,
        address _gatewayAddress,
        address _owner
    ) L1XERC20Adapter(_xerc20, _gatewayAddress, _owner) {}

    function setXERC20(address _xer20) public {
        xerc20 = _xer20;
    }
}
