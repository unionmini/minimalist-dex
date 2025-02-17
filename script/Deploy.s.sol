// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {WETH9} from "../src/test/WETH9.sol";
import {UniswapV2Router02} from "../src/periphery/UniswapV2Router.sol";

contract DeployUniswapV2 is Script {
    function run() external returns (UniswapV2Factory factory, WETH9 weth, UniswapV2Router02 router) {
        // Get feeToSetter address from environment, or use deployer if not set
        address feeToSetter = vm.envOr("FEE_TO_SETTER", address(vm.addr(vm.envUint("PRIVATE_KEY"))));

        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy UniswapV2Factory
        factory = new UniswapV2Factory(feeToSetter);

        // Deploy WETH
        weth = new WETH9();

        // Deploy UniswapV2Router
        router = new UniswapV2Router02(address(factory), address(weth));

        vm.stopBroadcast();
    }
}
