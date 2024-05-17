// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L1LockboxGateway } from "src/L1LockboxGateway.sol";
import { ICREATE3Factory } from "./utils/ICREATE3Factory.sol";

contract L1GatewayDeploy is Script {
    function run() public {
        string memory salt = vm.envString("GATEWAY_SALT");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        address create3Factory = vm.envAddress("CREATE3_FACTORY");
        address owner = vm.envAddress("L1_GATEWAY_OWNER");
        address router = vm.envAddress("L1_ARBITRUM_ROUTER");
        address lockbox = vm.envAddress("XERC20_LOCKBOX");
        address inbox = vm.envAddress("L1_ARBITRUM_INBOX");

        vm.startBroadcast(deployerPrivateKey);

        bytes32 _salt = keccak256(abi.encodePacked(salt, vm.addr(deployerPrivateKey)));

        bytes memory _creation = type(L1LockboxGateway).creationCode;
        bytes memory _bytecode = abi.encodePacked(_creation, abi.encode(lockbox, router, inbox, owner));

        ICREATE3Factory(create3Factory).deploy(_salt, _bytecode);

        vm.stopBroadcast();
    }
}
