// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { L2XERC20Gateway } from "src/L2XERC20Gateway.sol";

/**
 * @title L2LockboxGateway
 * @dev A Custom gateway that allows an Ethereum ERC20 token which can be deposited on an XERC20 Lockbox to be bridged
 * through the Arbitrum canonical bridge back to Ethereum from its Arbitrum XERC20 counterpart.
 * This gateway should be set as a bridge for the XERC20 token, and the user should previously grant XERC20 approval to
 * this contract before sending the tokens to Ethereum.
 * Also mints the L2 XERC20 token when the user sends tokens from Ethereum.
 *
 * @author BootNode
 */
contract L2LockboxGateway is L2XERC20Gateway {
    error NotImplementedFunction();

    /**
     * @dev Sets the L1 gateway counterpart, L2 Router and establishes the addresses of both L1 and L2 tokens allowed by
     * this gateway.
     */
    constructor(
        address _l1Counterpart,
        address _l2Router,
        address _l1Token,
        address _l2Token
    )
        L2XERC20Gateway(_l1Counterpart, _l2Router)
    {
        l1ToL2Token[_l1Token] = _l2Token;
    }

    /**
     * @dev Not implemented since L1/L2 token relation is being built upon deployment.
     */
    function registerTokenFromL1(address[] calldata, address[] calldata) external virtual override {
        revert NotImplementedFunction();
    }
}
