// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

/**
 * @title Interface needed to call function registerTokenToL2 of the L1CustomGateway
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

    function router() external view returns (address);
}
