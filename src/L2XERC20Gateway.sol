// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";

import { GatewayMessageHandler } from "@arbitrum/tokenbridge/libraries/gateway/GatewayMessageHandler.sol";

import { L2CustomGateway } from "src/vendor/L2CustomGateway.sol";

import { XERC20BaseGateway } from "src/XERC20BaseGateway.sol";

/**
 * @title L2XERC20Gateway
 * @dev A Custom gateway that allows XERC20 tokens to be bridged through the Arbitrum canonical bridge.
 * This gateway should be set as a bridge for the XERC20 token, and the user should previously grant approval to this
 * contract before sending the tokens to Arbitrum.
 * Burns L2 XERC20 when sending to Ethereum and mints it when the user sends tokens from Ethereum.
 *
 * @author BootNode
 */
contract L2XERC20Gateway is XERC20BaseGateway, L2CustomGateway {
    using Address for address;

    /**
     * @dev Sets the L1 gateway counterpart and L2 Router.
     */
    constructor(address _l1Counterpart, address _l2Router) {
        initialize(_l1Counterpart, _l2Router);
    }

    /**
     * @dev This function is called when initiating a token withdrawal from Arbitrum to Ethereum
     *
     * @param _l2Token Address of the XERC20 token
     * @param _from Address of the user sending the tokens to Ethereum
     * @param _amount Amount of tokens
     */
    function outboundEscrowTransfer(
        address _l2Token,
        address _from,
        uint256 _amount
    )
        internal
        override
        returns (uint256 amountBurnt)
    {
        return _outboundEscrowTransfer(_l2Token, _from, _amount);
    }

    /**
     * @dev Logic used when receiving tokens from Ethereum.
     *
     * @param _l2Token Address of the XERC20 token
     * @param _dest Address of the user receiving the tokens
     * @param _amount Amount of tokens
     */
    function inboundEscrowTransfer(address _l2Token, address _dest, uint256 _amount) internal override {
        _inboundEscrowTransfer(_l2Token, _dest, _amount);
    }

    /**
     * @notice Initiates a token withdrawal from Arbitrum to Ethereum
     * @param _l1Token l1 address of token
     * @param _to destination address
     * @param _amount amount of tokens withdrawn
     * @return res encoded unique identifier for withdrawal
     */
    function outboundTransfer(
        address _l1Token,
        address _to,
        uint256 _amount,
        uint256, /* _maxGas */
        uint256, /* _gasPriceBid */
        bytes calldata _data
    )
        public
        payable
        virtual
        override
        returns (bytes memory res)
    {
        // This function is set as public and virtual so that subclasses can override
        // it and add custom validation for callers (ie only whitelisted users)

        // the function is marked as payable to conform to the inheritance setup
        // this particular code path shouldn't have a msg.value > 0
        // TODO: remove this invariant for execution markets
        // solhint-disable-next-line
        require(msg.value == 0, "NO_VALUE");

        address _from;
        bytes memory _extraData;
        {
            if (isRouter(msg.sender)) {
                (_from, _extraData) = GatewayMessageHandler.parseFromRouterToGateway(_data);
            } else {
                _from = msg.sender;
                _extraData = _data;
            }
        }
        // the inboundEscrowAndCall functionality has been disabled, so no data is allowed
        // solhint-disable-next-line
        require(_extraData.length == 0, "EXTRA_DATA_DISABLED");

        uint256 id;
        {
            address l2Token = calculateL2TokenAddress(_l1Token);
            // solhint-disable-next-line
            require(l2Token.isContract(), "TOKEN_NOT_DEPLOYED");
            // ----------------- BEGIN MODIFICATION -----------------
            // As opposed to L2ERC20Gateway (which inherits from L2ArbitrumGateway
            // where this function is originally defined) `expectedAddress` is not
            // calculated, instead it comes from a mapping that can only be updated from
            // this gateway's L1 counterpart during initial token registration or
            // forced by L1's gateway owner so it's safe to assume that it's the
            // correct address and there's no need to do a double check.
            // require(IArbToken(l2Token).l1Address() == _l1Token, "NOT_EXPECTED_L1_TOKEN");
            // ----------------- END MODIFICATION -----------------

            _amount = outboundEscrowTransfer(l2Token, _from, _amount);
            id = triggerWithdrawal(_l1Token, _from, _to, _amount, _extraData);
        }
        return abi.encode(id);
    }

    /**
     * @notice Mint on L2 upon L1 deposit.
     * If token not yet deployed and symbol/name/decimal data is included, deploys StandardArbERC20
     * @dev Callable only by the L1ERC20Gateway.outboundTransfer method. For initial deployments of a token the L1
     * L1ERC20Gateway
     * is expected to include the deployData. If not a L1 withdrawal is automatically triggered for the user
     * @param _token L1 address of ERC20
     * @param _from account that initiated the deposit in the L1
     * @param _to account to be credited with the tokens in the L2 (can be the user's L2 account or a contract)
     * @param _amount token amount to be minted to the user
     * @param _data encoded symbol/name/decimal data for deploy, in addition to any additional callhook data
     */
    function finalizeInboundTransfer(
        address _token,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _data
    )
        external
        payable
        virtual
        override
        onlyCounterpartGateway
    {
        (bytes memory gatewayData, bytes memory callHookData) = GatewayMessageHandler.parseFromL1GatewayMsg(_data);

        if (callHookData.length != 0) {
            // callHookData should always be 0 since inboundEscrowAndCall is disabled
            callHookData = bytes("");
        }

        address expectedAddress = calculateL2TokenAddress(_token);

        if (!expectedAddress.isContract()) {
            bool shouldHalt = handleNoContract(_token, expectedAddress, _from, _to, _amount, gatewayData);
            if (shouldHalt) return;
        }
        // ignores gatewayData if token already deployed

        // ----------------- BEGIN MODIFICATION -----------------
        // As opposed to L2ERC20Gateway (which inherits from L2ArbitrumGateway
        // where this function is originally defined) `expectedAddress` is not
        // calculated, instead it comes from a mapping that can only be updated from
        // this gateway's L1 counterpart during initial token registration or
        // forced by L1's gateway owner so it's safe to assume that it's the
        // correct address and there's no need to do a double check.
        // {
        //     // validate if L1 address supplied matches that of the expected L2 address
        //     (bool success, bytes memory _l1AddressData) = expectedAddress.staticcall(
        //         abi.encodeWithSelector(IArbToken.l1Address.selector)
        //     );

        //     bool shouldWithdraw;
        //     if (!success || _l1AddressData.length < 32) {
        //         shouldWithdraw = true;
        //     } else {
        //         // we do this in the else branch since we want to avoid reverts
        //         // and `toAddress` reverts if _l1AddressData has a short length
        //         // `_l1AddressData` should be 12 bytes of padding then 20 bytes for the address
        //         address expectedL1Address = BytesLib.toAddress(_l1AddressData, 12);
        //         if (expectedL1Address != _token) {
        //             shouldWithdraw = true;
        //         }
        //     }

        //     if (shouldWithdraw) {
        //         // we don't need the return value from triggerWithdrawal since this is forcing
        //         // a withdrawal back to the L1 instead of composing with a L2 dapp
        //         triggerWithdrawal(_token, address(this), _from, _amount, "");
        //         return;
        //     }
        // }
        // ----------------- END MODIFICATION -----------------

        inboundEscrowTransfer(expectedAddress, _to, _amount);
        emit DepositFinalized(_token, _from, _to, _amount);

        return;
    }
}
