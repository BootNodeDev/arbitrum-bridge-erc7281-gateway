// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

interface IL1CustomGateway {
    function registerTokenToL2(
        address _l2Address,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost,
        address _creditBackAddress
    )
        external
        payable
        returns (uint256);

    function router() external returns (address);
}

interface IL1GatewayRouter {
    function setGateway(
        address _gateway,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        uint256 _maxSubmissionCost,
        address _creditBackAddress
    )
        external
        payable
        returns (uint256);
}

abstract contract L1ArbitrumEnabled {
    address internal gatewayAddress;

    constructor(address _gatewayAddress) {
        gatewayAddress = _gatewayAddress;
    }

    function isArbitrumEnabled() external pure returns (uint8) {
        return uint8(0xb1);
    }

    /// @dev Override should call _registerTokenOnL2 and be callable only by
    /// the owner of the token.
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
        virtual;

    function _registerTokenOnL2(
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
        internal
    {
        IL1CustomGateway gateway = IL1CustomGateway(gatewayAddress);

        gateway.registerTokenToL2{ value: valueForGateway }(
            l2TokenAddress, maxGasForGateway, gasPriceBid, maxSubmissionCostForGateway, creditBackAddress
        );
        IL1GatewayRouter(gateway.router()).setGateway{ value: valueForRouter }(
            gatewayAddress, maxGasForRouter, gasPriceBid, maxSubmissionCostForRouter, creditBackAddress
        );
    }
}
