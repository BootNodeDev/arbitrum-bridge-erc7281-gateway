// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { L1GatewayRouter } from "@arbitrum/tokenbridge/ethereum/gateway/L1GatewayRouter.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

contract L1ArbitrumEnabledXERC20TestToken is XERC20 {
    address internal gatewayAddress;

    constructor(address _gatewayAddress, address _owner) XERC20("ArbitrumEnabledToken", "AET", _owner) {
        gatewayAddress = _gatewayAddress;
    }

    function isArbitrumEnabled() external pure returns (uint8) {
        return uint8(0xb1);
    }

    function registerTokenOnL2(
        address l2TokenAddress,
        uint256 maxSubmissionCostForGateway,
        uint256 maxSubmissionCostForRouter,
        uint256 maxGasForGateway,
        uint256 maxGasForRouter,
        uint256 gasPriceBid,
        uint256 valueForGateway,
        uint256 valueForRouter,
        address creditBackAddress
    )
        public
        payable
        onlyOwner
    {
        L1XERC20Gateway gateway = L1XERC20Gateway(gatewayAddress);

        gateway.registerTokenToL2{ value: valueForGateway }(
            l2TokenAddress, maxGasForGateway, gasPriceBid, maxSubmissionCostForGateway, creditBackAddress
        );
        L1GatewayRouter(gateway.router()).setGateway{ value: valueForRouter }(
            gatewayAddress, maxGasForRouter, gasPriceBid, maxSubmissionCostForRouter, creditBackAddress
        );
    }
}
