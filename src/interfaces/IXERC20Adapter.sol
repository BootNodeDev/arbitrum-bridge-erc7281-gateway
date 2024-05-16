// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

/**
 * @title IXERC20Adapter
 * @dev The main purpose of this contract is to enable registering a non Arbitrum bridge compatible XERC20 token on
 * Arbitrum Bridge Router to be used along with the L1XERC20Gateway for bridging the token to Arbirtrum.
 *
 * @author BootNode
 */
interface IXERC20Adapter {
    /**
     * @dev Gets the XERC20 token address associated to this Adapter
     */
    function getXERC20() external view returns (address);
}
