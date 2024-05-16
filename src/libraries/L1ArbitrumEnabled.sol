// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { IL1CustomGateway } from "src/interfaces/IL1CustomGateway.sol";
import { IL1GatewayRouter } from "src/interfaces/IL1GatewayRouter.sol";

/**
 * @title L1ArbitrumEnabled
 * @dev This contract conforms with Arbitrum ICustomToken which is required for tokens to be pensionless registered on
 * Arbitrum Router to be used with a Custom Gateway
 *
 * @author BootNode
 */
abstract contract L1ArbitrumEnabled {
    address internal gatewayAddress;

    /**
     * @dev Sets the address of the gateway to be used for bridging
     */
    constructor(address _gatewayAddress) {
        gatewayAddress = _gatewayAddress;
    }

    /**
     * @dev Returns a magic value expected by the Arbitrum Router.
     */
    function isArbitrumEnabled() external pure returns (uint8) {
        return uint8(0xb1);
    }

    /**
     * @dev Override should call _registerTokenOnL2 and be callable only by the owner of the token.
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
        virtual;

    /**
     * @dev Sets the token/gateway relation on Arbitrum Router and registers the token on L2 counterpart gateway.
     */
    function _registerTokenOnL2(
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
        internal
    {
        IL1CustomGateway gateway = IL1CustomGateway(gatewayAddress);

        gateway.registerTokenToL2{ value: valueForGateway }(
            l2TokenAddress, maxGasForGateway, gasPriceBid, maxSubmissionCostForGateway, creditBackAddress
        );
        IL1GatewayRouter(gateway.router()).setGateway{ value: valueForRouter }(
            gatewayAddress, maxGasForRouter, gasPriceBid, maxSubmissionCostForRouter, creditBackAddress
        );
    }
}
