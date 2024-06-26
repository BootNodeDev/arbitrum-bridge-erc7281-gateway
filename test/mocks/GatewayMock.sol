// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { RouterMock } from "./RouterMock.sol";

contract GatewayMock {
    RouterMock internal routerContract;
    constructor() {
        routerContract = new RouterMock();
    }

    function registerTokenToL2(address, uint256, uint256, uint256, address) public payable returns (uint256) {
        return 1;
    }
    function router() public view returns(address) { return address(routerContract); }
}
