// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";
import {CREATE3} from 'solmate/utils/CREATE3.sol';

/// @title Factory for deploying contracts to deterministic addresses via CREATE3
/// @author zefram.eth
/// @notice Enables deploying contracts using CREATE3. Each deployer (msg.sender) has
/// its own namespace for deployed addresses.
interface ICREATE3Factory {
    /// @notice Deploys a contract using CREATE3
    /// @dev The provided salt is hashed together with msg.sender to generate the final salt
    /// @param salt The deployer-specific salt for determining the deployed contract's address
    /// @param creationCode The creation code of the contract to deploy
    /// @return deployed The address of the deployed contract
    function deploy(bytes32 salt, bytes memory creationCode)
        external
        payable
        returns (address deployed);

    /// @notice Predicts the address of a deployed contract
    /// @dev The provided salt is hashed together with the deployer address to generate the final salt
    /// @param deployer The deployer account that will call deploy()
    /// @param salt The deployer-specific salt for determining the deployed contract's address
    /// @return deployed The address of the contract that will be deployed
    function getDeployed(address deployer, bytes32 salt)
        external
        view
        returns (address deployed);
}

contract L1GatewayDeploy is  Script {
    string public constant SALT = 'XERC20Gateway-v0.2';
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        address owner = vm.envAddress("L1_GATEWAY_OWNER");
        address router = vm.envAddress("L1_ARBITRUM_ROUTER");
        address inbox = vm.envAddress("L1_ARBITRUM_INBOX");

        vm.startBroadcast(deployerPrivateKey);

        bytes32 _salt = keccak256(abi.encodePacked(SALT, msg.sender));

        bytes memory _creation = type(L1XERC20Gateway).creationCode;
        bytes memory _bytecode = abi.encodePacked(_creation, abi.encode(owner, router, inbox));

        ICREATE3Factory(0x93FEC2C00BfE902F733B57c5a6CeeD7CD1384AE1).deploy(_salt, _bytecode);

        vm.stopBroadcast();
    }
}
