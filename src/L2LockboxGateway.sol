// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { GatewayMessageHandler } from "@arbitrum/tokenbridge/libraries/gateway/GatewayMessageHandler.sol";

import { L2CustomGateway } from "src/vendor/L2CustomGateway.sol";

import { L2XERC20Gateway } from "src/L2XERC20Gateway.sol";

/**
 * @title Gateway for xERC20 bridging functionality
 */
contract L2LockboxGateway is L2XERC20Gateway {
    using Address for address;

    error NotImplementedFunction();

    constructor(
        address _l1Counterpart,
        address _l2Router,
        address _l1Token,
        address _l2Token
    )
        L2XERC20Gateway(_l1Counterpart, _l2Router)
    {
        l1ToL2Token[_l1Token] = _l2Token;
    }

    function registerTokenFromL1(address[] calldata, address[] calldata) external virtual override {
        revert NotImplementedFunction();
    }
}
