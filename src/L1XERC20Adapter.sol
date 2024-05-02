// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Owned } from "solmate/auth/Owned.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import { IL1GatewayRouter } from "@arbitrum/tokenbridge/ethereum/gateway/IL1GatewayRouter.sol";

import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";

contract L1XERC20Adapter is IXERC20Adapter, ERC165, Owned {
    address internal xerc20;
    address internal gatewayAddress;

    constructor(address _xerc20, address _gatewayAddress) Owned(msg.sender) {
        // TODO: maybe we should check whether the token is actually an XERC20
        xerc20 = _xerc20;
        gatewayAddress = _gatewayAddress;
    }

    function isArbitrumEnabled() external pure returns (uint8) {
        return uint8(0xb1);
    }

    function getXERC20() external view returns (address) {
        return xerc20;
    }

    function registerTokenOnL2(
        address l2TokenAddress,
        uint256 maxSubmissionCostForGateway,
        uint256 maxSubmissionCostForRouter,
        uint256 maxGasForGateway,
        uint256 maxGasForRouter,
        uint256 gasPriceBid,
        uint256 valueForGateway,
        uint256 valueForRouter,
        address creditBackAddress
    )
        public
        payable
        onlyOwner
    {
        L1XERC20Gateway gateway = L1XERC20Gateway(gatewayAddress);

        gateway.registerTokenToL2{ value: valueForGateway }(
            l2TokenAddress, maxGasForGateway, gasPriceBid, maxSubmissionCostForGateway, creditBackAddress
        );
        IL1GatewayRouter(gateway.router()).setGateway{ value: valueForRouter }(
            gatewayAddress, maxGasForRouter, gasPriceBid, maxSubmissionCostForRouter, creditBackAddress
        );
    }

    // Standard ERC20 view functions

    function name() external view returns (string memory) {
        return ERC20(xerc20).name();
    }

    function symbol() external view returns (string memory) {
        return ERC20(xerc20).symbol();
    }

    function decimals() external view returns (uint8) {
        return ERC20(xerc20).decimals();
    }

    function totalSupply() external view returns (uint256) {
        return ERC20(xerc20).totalSupply();
    }

    function balanceOf(address account) external view returns (uint256) {
        return ERC20(xerc20).balanceOf(account);
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return ERC20(xerc20).allowance(owner, spender);
    }

    // ERC165

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IXERC20Adapter).interfaceId || super.supportsInterface(interfaceId);
    }
}
