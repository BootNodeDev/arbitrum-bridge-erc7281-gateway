// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { XERC20Lockbox } from "xerc20/contracts/XERC20Lockbox.sol";

import { L1CustomGateway } from "@arbitrum/tokenbridge/ethereum/gateway/L1CustomGateway.sol";

import { XERC20BaseGateway } from "src/XERC20BaseGateway.sol";

/**
 * @title Gateway for xERC20 bridging functionality
 */
contract L1LockboxGateway is XERC20BaseGateway, L1CustomGateway {
    using SafeERC20 for IERC20;

    XERC20Lockbox internal lockbox;
    IERC20 internal l1Token;
    address internal xerc20;

    error InvalidToken();
    error NotImplementedFunction();

    constructor(address payable _lockbox, address _l1Router, address _inbox, address _owner) {
        address _l2Counterpart = address(this);

        lockbox = XERC20Lockbox(_lockbox);
        l1Token = lockbox.ERC20();
        xerc20 = address(lockbox.XERC20());
        l1ToL2Token[address(l1Token)] = xerc20;

        initialize(_l2Counterpart, _l1Router, _inbox, _owner);
    }

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

    function inboundEscrowTransfer(address _l1Token, address _dest, uint256 _amount) internal override {
        if (_l1Token != address(l1Token)) revert InvalidToken();

        _inboundEscrowTransfer(xerc20, address(this), _amount);
        IERC20(xerc20).approve(address(lockbox), _amount);
        lockbox.withdrawTo(_dest, _amount);
    }

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
