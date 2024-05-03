// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";
import { XERC20Factory } from "xerc20/contracts/XERC20Factory.sol";

contract XERC20FactoryDeploy is Script {
  string public constant SALT = 'xERC20-v1.5';

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PK");

    vm.startBroadcast(deployerPrivateKey);

    bytes32 _salt = keccak256(abi.encodePacked(SALT, msg.sender));

    new XERC20Factory{salt: _salt}();

    vm.stopBroadcast();
  }
}
