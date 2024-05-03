// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { XERC20Factory } from "xerc20/contracts/XERC20Factory.sol";

contract XERC20Deploy is Script {
  function run() public {
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");

    address factoryAdrress = vm.envAddress("XERC20_FACTORY");
    string memory name = vm.envString("XERC20_NAME");
    string memory symbol = vm.envString("XERC20_SYMBOL");

    uint256[] memory limits = vm.envOr("XERC20_BURN_MINT_LIMITS", ',', new uint256[](0));
    address[] memory bridges = vm.envOr("XERC20_BRIDGES", ',', new address[](0));

    vm.startBroadcast(deployerPrivateKey);

    XERC20Factory(factoryAdrress).deployXERC20(name, symbol, limits, limits, bridges);

    vm.stopBroadcast();
  }
}
