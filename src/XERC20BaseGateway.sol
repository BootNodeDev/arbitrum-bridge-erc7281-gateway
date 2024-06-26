// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { XERC20 } from "xerc20/contracts/XERC20.sol";

/**
 * @title XERC20BaseGateway
 * @dev Contains logic shared by both L1 and L2 gateways for minting and burning XERC20 tokens.
 *
 * @author BootNode
 */
abstract contract XERC20BaseGateway {
    function _outboundEscrowTransfer(
        address _token,
        address _from,
        uint256 _amount
    )
        internal
        virtual
        returns (uint256)
    {
        XERC20(_token).burn(_from, _amount);
        return _amount;
    }

    function _inboundEscrowTransfer(address _token, address _dest, uint256 _amount) internal virtual {
        XERC20(_token).mint(_dest, _amount);
    }
}
