// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { ArbERC20 } from "script/utils/ArbERC20.sol";

contract ERC20Register is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");

        ArbERC20 arbERC20 = ArbERC20(vm.envAddress("ARB_ERC20"));

        uint256 sendValue = vm.envOr("SEND_VALUE", uint256(0));
        uint256 maxSubmissionCostForRouter = vm.envOr("MAX_SUBMISSION_COST_FOR_ROUTER", uint256(0));
        uint256 maxGasForRouter = vm.envOr("MAX_GAS_FOR_ROUTER", uint256(0));
        uint256 gasPriceBid = vm.envOr("GAS_PRICE_BID", uint256(0));
        uint256 valueForRouter = vm.envOr("VALUE_FOR_ROUTER", uint256(0));
        address l1Gateway = vm.envAddress("L1_GATEWAY");
        address creditBackAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        arbERC20.registerTokenOnL2{ value: sendValue }(
            l1Gateway, maxSubmissionCostForRouter, maxGasForRouter, gasPriceBid, valueForRouter, creditBackAddress
        );

        vm.stopBroadcast();
    }
}
