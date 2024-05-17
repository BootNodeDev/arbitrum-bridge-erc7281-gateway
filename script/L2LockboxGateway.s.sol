// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L2LockboxGateway } from "src/L2LockboxGateway.sol";
import { ICREATE3Factory } from "./utils/ICREATE3Factory.sol";

contract L2GatewayDeploy is Script {
    function run() public {
        string memory salt = vm.envString("GATEWAY_SALT");
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");
        address create3Factory = vm.envAddress("CREATE3_FACTORY");
        address router = vm.envAddress("L2_ARBITRUM_ROUTER");
        address l1Counterpart = vm.envAddress("L1_GATEWAY");
        address l1Token = vm.envAddress("L1_ERC20");
        address l2Token = vm.envAddress("L2_XERC20");

        vm.startBroadcast(deployerPrivateKey);

        bytes32 _salt = keccak256(abi.encodePacked(salt, vm.addr(deployerPrivateKey)));

        bytes memory _creation = type(L2LockboxGateway).creationCode;
        bytes memory _bytecode = abi.encodePacked(_creation, abi.encode(l1Counterpart, router, l1Token, l2Token));

        ICREATE3Factory(create3Factory).deploy(_salt, _bytecode);

        vm.stopBroadcast();
    }
}
