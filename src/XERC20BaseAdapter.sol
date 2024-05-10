// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";

abstract contract XERC20BaseAdapter is IXERC20Adapter, ERC165, Ownable {
    address internal xerc20;

    constructor(address _xerc20) {
        // TODO: maybe we should check whether the token is actually an XERC20
        xerc20 = _xerc20;
    }

    function getXERC20() external view returns (address) {
        return xerc20;
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
