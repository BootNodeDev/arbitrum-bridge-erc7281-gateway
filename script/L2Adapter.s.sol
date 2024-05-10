// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L2XERC20Adapter } from "src/L2XERC20Adapter.sol";
import { ICREATE3Factory } from "./utils/ICREATE3Factory.sol";

contract L2AdapterDeploy is Script {
    string public constant SALT = "XERC20Adapter-v0.3";

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        address create3Factory = vm.envAddress("CREATE3_FACTORY");

        address owner = vm.envAddress("L2_ADAPTER_OWNER");
        address token = vm.envAddress("L2_XERC20");
        address gateway = vm.envAddress("L2_GATEWAY");
        address l1Adapter = vm.envAddress("L1_ADAPTER");

        vm.startBroadcast(deployerPrivateKey);

        bytes32 _salt = keccak256(abi.encodePacked(SALT, vm.addr(deployerPrivateKey)));

        bytes memory _creation = type(L2XERC20Adapter).creationCode;
        bytes memory _bytecode = abi.encodePacked(_creation, abi.encode(token, gateway, l1Adapter, owner));

        ICREATE3Factory(create3Factory).deploy(_salt, _bytecode);

        vm.stopBroadcast();
    }
}
