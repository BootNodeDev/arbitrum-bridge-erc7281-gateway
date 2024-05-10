// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { XERC20BaseAdapter } from "src/XERC20BaseAdapter.sol";

contract L2XERC20Adapter is XERC20BaseAdapter {
    address public l1Address;

    constructor(address _xerc20, address _l1AdapterOrToken) XERC20BaseAdapter(_xerc20) {
        l1Address = _l1AdapterOrToken;
    }
}
