// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { ERC20 } from "@openzeppelin/contracts/token/erc20/ERC20.sol";

contract XERC20Adapter {
    address internal xerc20;

    constructor(address _xerc20) {
        xerc20 = _xerc20;
    }

    function isArbitrumEnabled() external pure returns (uint8) {
        return uint8(0xb1);
    }

    function getXERC20() external view returns (address) {
        return xerc20;
    }

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
}
