// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { L1ArbitrumEnabled } from "src/libraries/L1ArbitrumEnabled.sol";

/**
 * @title L1ArbitrumEnabledXERC20
 * @dev Extended version of a XERC20 token conforms with Arbitrum ICustomToken.
 *
 * @author BootNode
 */
contract L1ArbitrumEnabledXERC20 is XERC20, L1ArbitrumEnabled {
    /**
     * @dev Sets the token name, symbol and owner, and the gateway to be registered on Arbitrum Router.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _owner,
        address _gatewayAddress
    )
        XERC20(_name, _symbol, _owner)
        L1ArbitrumEnabled(_gatewayAddress)
    { }

    /**
     * @dev Sets the token/gateway relation on Arbitrum Router and registers the token on L2 counterpart gateway.
     *
     * @param l2TokenAddress Address of the counterpart token on L2
     * @param maxSubmissionCostForGateway Base submission cost L2 retryable ticket for gateway
     * @param maxSubmissionCostForRouter Base submission cost L2 retryable ticket for router
     * @param maxGasForGateway Max gas for L2 retryable execution for gateway message
     * @param maxGasForRouter Max gas for L2 retryable execution for router message
     * @param gasPriceBid Gas price for L2 retryable ticket
     * @param valueForGateway ETH value to transfer to the gateway
     * @param valueForRouter ETH value to transfer to the gateway
     * @param creditBackAddress Address for crediting back overpayment of _maxSubmissionCost
     */
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
        checkValue(valueForGateway + valueForRouter)
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
