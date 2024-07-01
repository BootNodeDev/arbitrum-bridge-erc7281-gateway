// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import { L1CustomGateway } from "@arbitrum/tokenbridge/ethereum/gateway/L1CustomGateway.sol";

import { XERC20BaseGateway } from "src/XERC20BaseGateway.sol";

import { IXERC20Adapter } from "src/interfaces/IXERC20Adapter.sol";

/**
 * @title L1XERC20Gateway
 * @dev A Custom gateway that allows XERC20 tokens to be bridged through the Arbitrum canonical bridge.
 * This gateway should be set as a bridge for the XERC20 token, and the user should previously grant approval to this
 * contract before sending the tokens to Arbitrum.
 * Burns L1 XERC20 when sending to Arbitrum and mints it when the user sends tokens from Arbitrum.
 *
 * @author BootNode
 */
contract L1XERC20Gateway is XERC20BaseGateway, L1CustomGateway {
    using ERC165Checker for address;

    // stores addresses of registered tokens
    mapping(address => address) public adapterToToken;
    mapping(address => bool) public l1RegisteredTokens;
    mapping(address => bool) public l2RegisteredTokens;

    error AlreadyRegisteredL1Token();
    error AlreadyRegisteredL2Token();
    error InvalidLengths();
    error NotRegisteredToken();

    /**
     * @dev Sets the arbitrum router, inbox and the owner of this contract.
     */
    constructor(address _l1Router, address _inbox, address _owner) {
        address _l2Counterpart = address(this);
        initialize(_l2Counterpart, _l1Router, _inbox, _owner);
    }

    function addressIsAdapter(address _tokenOrAdapter) public view returns (bool) {
        return _tokenOrAdapter.supportsInterface(type(IXERC20Adapter).interfaceId);
    }

    /**
     * @notice Override L1CustomGateway function for validating already registered tokens.
     */
    function registerTokenToL2(
        address _l2Address,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost,
        address _creditBackAddress
    )
        public
        payable
        virtual
        override
        returns (uint256)
    {
        address _l1Token = msg.sender;

        if (addressIsAdapter(msg.sender)) {
            _l1Token = IXERC20Adapter(_l1Token).getXERC20();
        }

        if (l1RegisteredTokens[_l1Token]) revert AlreadyRegisteredL1Token();
        if (l2RegisteredTokens[_l2Address]) revert AlreadyRegisteredL2Token();

        adapterToToken[msg.sender] = _l1Token;
        l1RegisteredTokens[_l1Token] = true;
        l2RegisteredTokens[_l2Address] = true;

        return _registerTokenToL2(_l2Address, _maxGas, _gasPriceBid, _maxSubmissionCost, _creditBackAddress, msg.value);
    }

    /**
     * @notice Override L1CustomGateway function setting l1RegisteredTokens and l2RegisteredTokens.
     * It assumes the owner checked both addresses offchain before force registering. Multi-sig or governance is
     * recommended be used as the owner
     */
    function forceRegisterTokenToL2(
        address[] calldata _l1Addresses,
        address[] calldata _l2Addresses,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost
    )
        external
        payable
        virtual
        override
        onlyOwner
        returns (uint256)
    {
        if (_l1Addresses.length != _l2Addresses.length) revert InvalidLengths();

        address _l1Token;
        for (uint256 i = 0; i < _l1Addresses.length; i++) {
            _l1Token = _l1Addresses[i];

            if (addressIsAdapter(_l1Addresses[i])) {
                _l1Token = IXERC20Adapter(_l1Token).getXERC20();
            }

            adapterToToken[_l1Addresses[i]] = _l1Token;
            l1RegisteredTokens[_l1Token] = true;
            l2RegisteredTokens[_l2Addresses[i]] = true;
        }

        return _forceRegisterTokenToL2(_l1Addresses, _l2Addresses, _maxGas, _gasPriceBid, _maxSubmissionCost, msg.value);
    }

    /**
     * @dev This function is called inside the `outboundTransferCustomRefund` when the token is being bridged from
     * Ethereum to Arbitrum.
     *
     * @param _l1TokenOrAdapter Address of the XERC20 token or its adapter
     * @param _from Address of the user sending the tokens to Arbitrum
     * @param _amount Amount of tokens
     */
    function outboundEscrowTransfer(
        address _l1TokenOrAdapter,
        address _from,
        uint256 _amount
    )
        internal
        override
        returns (uint256 amountReceived)
    {
        address _token = adapterToToken[_l1TokenOrAdapter];

        if (_token == address(0)) revert NotRegisteredToken();

        return _outboundEscrowTransfer(_token, _from, _amount);
    }

    /**
     * @dev Logic used when withdrawing tokens from Arbitrum.
     *
     * @param _l1TokenOrAdapter Address of the XERC20 token or its adapter
     * @param _dest Address of the user receiving the tokens
     * @param _amount Amount of tokens
     */
    function inboundEscrowTransfer(address _l1TokenOrAdapter, address _dest, uint256 _amount) internal override {
        address _token = adapterToToken[_l1TokenOrAdapter];

        if (_token == address(0)) revert NotRegisteredToken();

        _inboundEscrowTransfer(_token, _dest, _amount);
    }
}
