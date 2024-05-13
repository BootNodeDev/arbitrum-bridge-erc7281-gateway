// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1ArbitrumEnabled } from "src/libraries/L1ArbitrumEnabled.sol";

contract L1ArbitrumEnabledXERC20 is XERC20, L1ArbitrumEnabled {
    constructor(
        string memory _name,
        string memory _symbol,
        address _owner,
        address _gatewayAddress
    )
        XERC20(_name, _symbol, _owner)
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
