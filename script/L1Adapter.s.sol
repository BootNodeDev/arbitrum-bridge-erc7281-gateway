// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";

contract L1AdapterDeploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        address owner = vm.envAddress("L1_ADAPTER_OWNER");
        address token = vm.envAddress("L1_XERC20");
        address gateway = vm.envAddress("L1_GATEWAY");

        vm.startBroadcast(deployerPrivateKey);

        new L1XERC20Adapter(token, gateway, owner);

        vm.stopBroadcast();
    }
}
