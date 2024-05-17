// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { XERC20Lockbox } from "xerc20/contracts/XERC20Lockbox.sol";

import { L1CustomGateway } from "@arbitrum/tokenbridge/ethereum/gateway/L1CustomGateway.sol";

import { XERC20BaseGateway } from "src/XERC20BaseGateway.sol";

/**
 * @title L1LockboxGateway
 * @dev A Custom gateway that allows an ERC20 token which can be deposited on an XERC20 Lockbox to be bridged through the
 * Arbitrum canonical bridge.
 * This gateway should be set as a bridge for the XERC20 token, and the user should previously grant ERC20 approval to
 * this contract before sending the tokens to Arbitrum.
 * It also withdraws the ERC20 form the Lockbox when the user sends tokens from Arbitrum.
 *
 * @author BootNode
 */
contract L1LockboxGateway is XERC20BaseGateway, L1CustomGateway {
    using SafeERC20 for IERC20;

    XERC20Lockbox internal lockbox;
    IERC20 internal l1Token;
    address internal xerc20;

    error InvalidToken();
    error NotImplementedFunction();

    /**
     * @dev Sets the lockbox, l1Router, inbox and owner. It also establishes the addresses of both L1 and L2 tokens allowed by
     * this gateway.
     */
    constructor(address payable _lockbox, address _l1Router, address _inbox, address _owner) {
        address _l2Counterpart = address(this);

        lockbox = XERC20Lockbox(_lockbox);
        l1Token = lockbox.ERC20();
        xerc20 = address(lockbox.XERC20());
        l1ToL2Token[address(l1Token)] = xerc20;

        initialize(_l2Counterpart, _l1Router, _inbox, _owner);
    }

    /**
     * @dev This function is called inside the `outboundTransferCustomRefund` when the token is being bridged from
     * Ethereum to Arbitrum. It contains the logic for depositing the ERC20 token into the Lockbox.
     *
     * @param _l1Token Address of the ERC20 token
     * @param _from Address of the user sending the tokens to Arbitrum
     * @param _amount Amount of tokens
     */
    function outboundEscrowTransfer(
        address _l1Token,
        address _from,
        uint256 _amount
    )
        internal
        override
        returns (uint256 amountReceived)
    {
        if (_l1Token != address(l1Token)) revert InvalidToken();

        l1Token.safeTransferFrom(_from, address(this), _amount);
        l1Token.approve(address(lockbox), _amount);
        lockbox.deposit(_amount);
        return _outboundEscrowTransfer(xerc20, address(this), _amount);
    }

    /**
     * @dev Logic used when withdrawing tokens from Arbitrum for transforming the XERC20 representation into the
     * canonical ERC20.
     *
     * @param _l1Token Address of the ERC20 token
     * @param _dest Address of the user receiving the tokens
     * @param _amount Amount of tokens
     */
    function inboundEscrowTransfer(address _l1Token, address _dest, uint256 _amount) internal override {
        if (_l1Token != address(l1Token)) revert InvalidToken();

        _inboundEscrowTransfer(xerc20, address(this), _amount);
        IERC20(xerc20).approve(address(lockbox), _amount);
        lockbox.withdrawTo(_dest, _amount);
    }

    /**
     * @dev Not implemented since L1/L2 token relation is being built upon deployment.
     */
    function registerTokenToL2(
        address,
        uint256,
        uint256,
        uint256
    )
        external
        payable
        virtual
        override
        returns (uint256)
    {
        revert NotImplementedFunction();
    }

    /**
     * @dev Not implemented since L1/L2 token relation is being built upon deployment.
     */
    function registerTokenToL2(
        address,
        uint256,
        uint256,
        uint256,
        address
    )
        public
        payable
        virtual
        override
        returns (uint256)
    {
        revert NotImplementedFunction();
    }

    /**
     * @dev Not implemented since L1/L2 token relation is being built upon deployment.
     */
    function forceRegisterTokenToL2(
        address[] calldata,
        address[] calldata,
        uint256,
        uint256,
        uint256
    )
        external
        payable
        virtual
        override
        returns (uint256)
    {
        revert NotImplementedFunction();
    }
}
