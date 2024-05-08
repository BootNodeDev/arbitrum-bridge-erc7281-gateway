// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { XERC20 } from "xerc20/contracts/XERC20.sol";

contract L2ArbitrumEnabledXERC20TestToken is XERC20 {
    address public l1Address;

    constructor(address _l1Address, address _owner) XERC20("ArbitrumEnabledToken", "AET", _owner) {
        l1Address = _l1Address;
    }
}
