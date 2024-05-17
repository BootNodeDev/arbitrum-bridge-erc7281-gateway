// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { IL1CustomGateway } from "src/interfaces/IL1CustomGateway.sol";
import { IL1GatewayRouter } from "src/interfaces/IL1GatewayRouter.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { L1ArbitrumEnabled } from "src/libraries/L1ArbitrumEnabled.sol";

contract ArbERC20 is ERC20 {
    address public owner;

    error NotOwner();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner
    )
        ERC20(_name, _symbol)
    {
        _mint(_owner, _initialSupply);
        owner = _owner;
    }

    function isArbitrumEnabled() external pure returns (uint8) {
        return uint8(0xb1);
    }

    function registerTokenOnL2(
        address _gatewayAddress,
        uint256 maxSubmissionCostForRouter,
        uint256 maxGasForRouter,
        uint256 gasPriceBid,
        uint256 valueForRouter,
        address creditBackAddress
    )
        public
        payable
        onlyOwner
    {
        IL1CustomGateway gateway = IL1CustomGateway(_gatewayAddress);

        IL1GatewayRouter(gateway.router()).setGateway{ value: valueForRouter }(
            _gatewayAddress, maxGasForRouter, gasPriceBid, maxSubmissionCostForRouter, creditBackAddress
        );
    }
}
