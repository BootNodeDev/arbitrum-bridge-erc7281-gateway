// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { IL1CustomGateway } from "src/interfaces/IL1CustomGateway.sol";

contract RouterMock {
    function setGateway(IL1CustomGateway, uint256, uint256, uint256, address) public payable returns (uint256) {
        return 1;
    }
}
