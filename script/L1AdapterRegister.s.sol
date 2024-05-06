// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";

contract L1AdapterRegister is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");

        L1XERC20Adapter adapter = L1XERC20Adapter(vm.envAddress("L1_ADAPTER"));
        address l2TokenAddress = vm.envAddress("L2_ADAPTER");
        uint256 maxSubmissionCostForGateway = 100_000_000_000_000_000;
        uint256 maxSubmissionCostForRouter = 100_000_000_000_000_000;
        uint256 maxGasForGateway = 2_000_000;
        uint256 maxGasForRouter = 2_000_000;
        uint256 gasPriceBid = 1_011_990_000;
        uint256 valueForGateway = 110_000_000_000_000_000;
        uint256 valueForRouter = 110_000_000_000_000_000;
        address creditBackAddress = vm.envAddress("DEPLOYER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        adapter.registerTokenOnL2{ value: 220_000_000_000_000_000 }(
            l2TokenAddress,
            maxSubmissionCostForGateway,
            maxSubmissionCostForRouter,
            maxGasForGateway,
            maxGasForRouter,
            gasPriceBid,
            valueForGateway,
            valueForRouter,
            creditBackAddress
        );

        vm.stopBroadcast();
    }
}
