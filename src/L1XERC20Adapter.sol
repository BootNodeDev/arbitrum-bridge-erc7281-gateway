// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { XERC20BaseAdapter } from "src/XERC20BaseAdapter.sol";
import { L1ArbitrumEnabled } from "src/libraries/L1ArbitrumEnabled.sol";

contract L1XERC20Adapter is XERC20BaseAdapter, L1ArbitrumEnabled {
    constructor(
        address _xerc20,
        address _gatewayAddress
    )
        XERC20BaseAdapter(_xerc20)
        L1ArbitrumEnabled(_gatewayAddress)
    { }

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
        override
        onlyOwner
    {
        _registerTokenOnL2(
            l2TokenAddress,
            maxSubmissionCostForGateway,
            maxSubmissionCostForRouter,
            maxGasForGateway,
            maxGasForRouter,
            gasPriceBid,
            valueForGateway,
            valueForRouter,
            creditBackAddress
        );
    }
}
