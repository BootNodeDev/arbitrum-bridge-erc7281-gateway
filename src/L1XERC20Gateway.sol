// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { L1CustomGateway } from "@arbitrum/tokenbridge/ethereum/gateway/L1CustomGateway.sol";

import { XERC20BaseGateway } from "src/XERC20BaseGateway.sol";

/**
 * @title L1XERC20Gateway
 * @dev A Custom gateway that allows XERC20 tokens to be bridge through Arbitrum canonical bridge.
 * This gateway should be set as a bridge for the XER20 token, and the user should previously grant approval to this
 * contract before sending the tokens to Arbitrum.
 * Burns L1 XERC20 when sending to Arbitrum and mints it when the user sends tokens from Arbitrum.
 *
 * @author BootNode
 */
contract L1XERC20Gateway is XERC20BaseGateway, L1CustomGateway {
    /**
     * @dev Sets the arbitrum router, inbox and the owner of this contract.
     */
    constructor(address _l1Router, address _inbox, address _owner) {
        address _l2Counterpart = address(this);
        initialize(_l2Counterpart, _l1Router, _inbox, _owner);
    }

    /**
     * @dev This function is called inside the `outboundTransferCustomRefund` when the token is being bridged from
     * Ethereum to Arbitrum.
     *
     * @param _l1Token Address of the XERC20 token
     * @param _from Address of the user sending the tokens to Arbitrum
     * @param _amount Amount of tokens
     */
    function outboundEscrowTransfer(
        address _l1TokenOrAdapter,
        address _from,
        uint256 _amount
    )
        internal
        override
        returns (uint256 amountReceived)
    {
        return _outboundEscrowTransfer(_l1TokenOrAdapter, _from, _amount);
    }

    /**
     * @dev Logic used when withdrawing tokens from Arbitrum.
     *
     * @param _l1Token Address of the XERC20 token
     * @param _dest Address of the user receiving the tokens
     * @param _amount Amount of tokens
     */
    function inboundEscrowTransfer(address _l1TokenOrAdapter, address _dest, uint256 _amount) internal override {
        _inboundEscrowTransfer(_l1TokenOrAdapter, _dest, _amount);
    }
}
