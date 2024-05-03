// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { L1CustomGateway } from "@arbitrum/tokenbridge/ethereum/gateway/L1CustomGateway.sol";

import { XERC20BaseGateway } from "src/XERC20BaseGateway.sol";

/**
 * @title Gateway for xERC20 bridging functionality
 */
contract L1XERC20Gateway is XERC20BaseGateway, L1CustomGateway {
    constructor(address _owner, address _l1Router, address _inbox) {
        address _l2Counterpart = address(this);
        initialize(_l2Counterpart, _l1Router, _inbox, _owner);
    }

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

    function inboundEscrowTransfer(address _l1TokenOrAdapter, address _dest, uint256 _amount) internal override {
        _inboundEscrowTransfer(_l1TokenOrAdapter, _dest, _amount);
    }
}
