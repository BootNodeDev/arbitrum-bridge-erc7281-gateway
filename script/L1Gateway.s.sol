// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L1XERC20Gateway } from "src/L1XERC20Gateway.sol";
import { ICREATE3Factory } from "./utils/ICREATE3Factory.sol";

contract L1GatewayDeploy is Script {
    string public constant SALT = "XERC20Gateway-v0.3";

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        address create3Fatory = vm.envAddress("CREATE3_FACTORY");
        address owner = vm.envAddress("L1_GATEWAY_OWNER");
        address router = vm.envAddress("L1_ARBITRUM_ROUTER");
        address inbox = vm.envAddress("L1_ARBITRUM_INBOX");

        vm.startBroadcast(deployerPrivateKey);

        bytes32 _salt = keccak256(abi.encodePacked(SALT, vm.addr(deployerPrivateKey)));

        bytes memory _creation = type(L1XERC20Gateway).creationCode;
        bytes memory _bytecode = abi.encodePacked(_creation, abi.encode(owner, router, inbox));

        ICREATE3Factory(create3Fatory).deploy(_salt, _bytecode);

        vm.stopBroadcast();
    }
}
