// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import { XERC20 } from "xerc20/contracts/XERC20.sol";

import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";

abstract contract XERC20BaseGateway {
    using ERC165Checker for address;

    function addressIsAdapter(address _tokenOrAdapter) public view returns (bool) {
        return _tokenOrAdapter.supportsInterface(type(IXERC20Adapter).interfaceId);
    }

    function _outboundEscrowTransfer(
        address _tokenOrAdapter,
        address _from,
        uint256 _amount
    )
        internal
        virtual
        returns (uint256)
    {
        address _token = _tokenOrAdapter;

        if (addressIsAdapter(_tokenOrAdapter)) {
            _token = IXERC20Adapter(_tokenOrAdapter).getXERC20();
        }

        XERC20(_token).burn(_from, _amount);
        return _amount;
    }

    function _inboundEscrowTransfer(address _tokenOrAdapter, address _dest, uint256 _amount) internal virtual {
        address _token = _tokenOrAdapter;

        if (addressIsAdapter(_tokenOrAdapter)) {
            _token = IXERC20Adapter(_tokenOrAdapter).getXERC20();
        }
        XERC20(_token).mint(_dest, _amount);
    }
}
