// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { L1XERC20Adapter } from "src/L1XERC20Adapter.sol";

contract L1AdapterRegister is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("L1_ADAPTER_OWNER_PK");

        L1XERC20Adapter adapter = L1XERC20Adapter(vm.envAddress("L1_ADAPTER"));

        uint256 sendValue = vm.envOr("SEND_VALUE", uint256(0));
        address l2TokenAddress = vm.envAddress("L2_XERC20");
        uint256 maxSubmissionCostForGateway = vm.envOr("MAX_SUBMISSION_COST_FOR_GATEWAY", uint256(0));
        uint256 maxSubmissionCostForRouter = vm.envOr("MAX_SUBMISSION_COST_FOR_ROUTER", uint256(0));
        uint256 maxGasForGateway = vm.envOr("MAX_GAS_FOR_GATEWAY", uint256(0));
        uint256 maxGasForRouter = vm.envOr("MAX_GAS_FOR_ROUTER", uint256(0));
        uint256 gasPriceBid = vm.envOr("GAS_PRICE_BID", uint256(0));
        uint256 valueForGateway = vm.envOr("VALUE_FOR_GATEWAY", uint256(0));
        uint256 valueForRouter = vm.envOr("VALUE_FOR_ROUTER", uint256(0));
        address creditBackAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        adapter.registerTokenOnL2{ value: sendValue }(
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
