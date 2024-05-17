// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

/**
 * @dev Arbitrum's IL1CustomGateway interface required for the L1ArbitrumEnabled
 */
interface IL1CustomGateway {
    function registerTokenToL2(
        address _l2Address,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost,
        address _creditBackAddress
    )
        external
        payable
        returns (uint256);

    function router() external returns (address);
}
