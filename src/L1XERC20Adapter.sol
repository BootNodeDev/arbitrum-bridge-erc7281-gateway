// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { XERC20BaseAdapter } from "src/XERC20BaseAdapter.sol";
import { L1ArbitrumEnabled } from "src/libraries/L1ArbitrumEnabled.sol";

/**
 * @title L1XERC20Adapter
 * @dev This contract can be used for permissionless registration of a non Arbitrum compatible token on the Arbitrum
 * Router to be used with a Custom Gateway.
 * By doing so, take into account that the address of this contract is the one registered on the router, so use that
 * address when calling `L1GatewayRouter.outboundTransferCustomRefund`, also that the user should previously grant
 * approval to the gateway so it can burn its token.
 *
 * @author BootNode
 */
contract L1XERC20Adapter is XERC20BaseAdapter, L1ArbitrumEnabled, Ownable {
    /**
     * @dev Sets the XERC20 token, the gateway and the owner.
     */
    constructor(
        address _xerc20,
        address _gatewayAddress,
        address _owner
    )
        XERC20BaseAdapter(_xerc20)
        L1ArbitrumEnabled(_gatewayAddress)
    {
        _transferOwnership(_owner);
    }

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
