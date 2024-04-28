// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { IERC165 } from "@openzeppelin/contracts/interfaces/IERC165.sol";

interface IXERC20Adapter {
    function isArbitrumEnabled() external view returns (uint8);
    function getXERC20() external view returns (address);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}
