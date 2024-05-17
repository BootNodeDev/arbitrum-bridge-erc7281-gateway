// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { XERC20Factory } from "xerc20/contracts/XERC20Factory.sol";

import { ArbERC20 } from "script/utils/ArbERC20.sol";

contract LockboxDeploy is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");

        address factoryAdrress = vm.envAddress("XERC20_FACTORY");
        string memory xname = vm.envString("XERC20_NAME");
        string memory xsymbol = vm.envString("XERC20_SYMBOL");

        string memory name = vm.envString("ERC20_NAME");
        string memory symbol = vm.envString("ERC20_SYMBOL");
        uint256 initialSupply = vm.envUint("ERC20_INITIAL_SUPPLY");
        address owner = vm.envAddress("ERC20_OWNER");

        uint256[] memory limits = vm.envOr("XERC20_BURN_MINT_LIMITS", ",", new uint256[](0));
        address[] memory bridges = vm.envOr("XERC20_BRIDGES", ",", new address[](0));

        vm.startBroadcast(deployerPrivateKey);

        ArbERC20 theERC20 = new ArbERC20(name, symbol, initialSupply, owner);

        address theXERC20 = XERC20Factory(factoryAdrress).deployXERC20(xname, xsymbol, limits, limits, bridges);

        XERC20Factory(factoryAdrress).deployLockbox(theXERC20, address(theERC20), false);

        vm.stopBroadcast();
    }
}
