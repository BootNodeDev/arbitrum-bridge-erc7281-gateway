// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { L2CustomGateway } from "src/vendor/L2CustomGateway.sol";

import { XERC20BaseGateway } from "src/XERC20BaseGateway.sol";

/**
 * @title Gateway for xERC20 bridging functionality
 */
contract L2XERC20Gateway is XERC20BaseGateway, L2CustomGateway {
    constructor(address _l1Counterpart, address _l2Router) {
        initialize(_l1Counterpart, _l2Router);
    }

    function outboundEscrowTransfer(
        address _l2TokenOrAdapter,
        address _from,
        uint256 _amount
    )
        internal
        override
        returns (uint256 amountBurnt)
    {
        return _outboundEscrowTransfer(_l2TokenOrAdapter, _from, _amount);
    }

    function inboundEscrowTransfer(address _l2TokenOrAdapter, address _dest, uint256 _amount) internal override {
        _inboundEscrowTransfer(_l2TokenOrAdapter, _dest, _amount);
    }
}
