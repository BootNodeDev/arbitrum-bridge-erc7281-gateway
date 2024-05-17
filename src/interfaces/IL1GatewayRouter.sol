// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

/**
 * @dev Arbitrum's IL1CustomGateway interface required for the L1ArbitrumEnabled
 */
interface IL1GatewayRouter {
    function setGateway(
        address _gateway,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost,
        address _creditBackAddress
    )
        external
        payable
        returns (uint256);
}