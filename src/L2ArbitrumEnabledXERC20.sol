// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { XERC20 } from "xerc20/contracts/XERC20.sol";

contract L2ArbitrumEnabledXERC20 is XERC20 {
    address public l1Address;

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
