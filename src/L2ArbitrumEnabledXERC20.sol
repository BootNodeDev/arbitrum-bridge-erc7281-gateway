// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { XERC20 } from "xerc20/contracts/XERC20.sol";

/**
 * @title L2ArbitrumEnabledXERC20
 * @dev Extended version of a XERC20 token conforms with Arbitrum ICustomToken.
 *
 * @author BootNode
 */
contract L2ArbitrumEnabledXERC20 is XERC20 {
    address public l1Address;

    /**
     * @dev Sets the token name, symbol and owner, the L1 token counterpart.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _owner,
        address _l1Address
    )
        XERC20(_name, _symbol, _owner)
    {
        l1Address = _l1Address;
    }
}
