// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";
import { ICREATE3Factory } from "./utils/ICREATE3Factory.sol";

import { console2 } from "forge-std/console2.sol";

contract L1AdapterDeploy is Script {
    string public constant SALT = "XERC20Adapter-v0.3";

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        address create3Fatory = vm.envAddress("CREATE3_FACTORY");

        address owner = vm.envAddress("L1_ADAPTER_OWNER");
        address token = vm.envAddress("L1_XERC20");
        address gateway = vm.envAddress("L1_GATEWAY");

        vm.startBroadcast(deployerPrivateKey);

        bytes32 _salt = keccak256(abi.encodePacked(SALT, vm.addr(deployerPrivateKey)));

        bytes memory _creation = type(L1XERC20Adapter).creationCode;
        bytes memory _bytecode = abi.encodePacked(_creation, abi.encode(token, gateway, owner));

        ICREATE3Factory(create3Fatory).deploy(_salt, _bytecode);

        vm.stopBroadcast();
    }
}
