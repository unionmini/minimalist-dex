// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";

contract DeployUniswapV2 is Script {
    function run() external returns (UniswapV2Factory factory) {
        // Get deployer's private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get feeToSetter address from environment, or use deployer if not set
        address feeToSetter = vm.envOr("FEE_TO_SETTER", address(vm.addr(deployerPrivateKey)));

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy UniswapV2Factory
        factory = new UniswapV2Factory(feeToSetter);

        vm.stopBroadcast();
    }
}
