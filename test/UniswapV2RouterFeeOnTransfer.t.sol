// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Router02} from "../src/periphery/UniswapV2Router.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";
import {WETH9} from "../src/test/WETH9.sol";
import {DeflatingERC20} from "../src/test/DeflatingERC20.sol";
import {Utilities} from "./shared/Utilities.sol";

contract UniswapV2RouterFeeOnTransferTest is Test {
    using Utilities for uint256;

    UniswapV2Factory public factory;
    UniswapV2Router02 public router;
    DeflatingERC20 public dtt;
    WETH9 public weth;
    UniswapV2Pair public pair;
    address public wallet = address(this);

    function setUp() public {
        weth = new WETH9();
        factory = new UniswapV2Factory(wallet);
        router = new UniswapV2Router02(address(factory), address(weth));
        dtt = new DeflatingERC20(10000 * 10 ** 18);

        factory.createPair(address(dtt), address(weth));
        pair = UniswapV2Pair(factory.getPair(address(dtt), address(weth)));
    }

    function testRemoveLiquidityETHSupportingFeeOnTransferTokens() public {
        uint256 dttAmount = 1 * 10 ** 18;
        uint256 ethAmount = 4 * 10 ** 18;
        addLiquidity(dttAmount, ethAmount);

        uint256 dttInPair = dtt.balanceOf(address(pair));
        uint256 wethInPair = weth.balanceOf(address(pair));
        uint256 liquidity = pair.balanceOf(wallet);
        uint256 totalSupply = pair.totalSupply();
        uint256 naiveDttExpected = (dttInPair * liquidity) / totalSupply;
        uint256 wethExpected = (wethInPair * liquidity) / totalSupply;

        pair.approve(address(router), type(uint256).max);
        router.removeLiquidityETHSupportingFeeOnTransferTokens(
            address(dtt), liquidity, naiveDttExpected, wethExpected, wallet, type(uint256).max
        );
    }

    function addLiquidity(uint256 dttAmount, uint256 wethAmount) internal {
        dtt.approve(address(router), type(uint256).max);
        router.addLiquidityETH{value: wethAmount}(
            address(dtt), dttAmount, dttAmount, wethAmount, wallet, type(uint256).max
        );
    }

    function testSwapExactTokensForTokensSupportingFeeOnTransferTokens() public {
        // Break down calculation into steps
        uint256 baseAmount = 5 * 10 ** 18;
        uint256 dttAmount = baseAmount * 100;
        dttAmount = dttAmount / 99; // Now it's a clean integer division

        uint256 ethAmount = 10 * 10 ** 18;
        uint256 amountIn = 1 * 10 ** 18;

        addLiquidity(dttAmount, ethAmount);

        // Test DTT -> WETH
        dtt.approve(address(router), type(uint256).max);
        address[] memory path = new address[](2);
        path[0] = address(dtt);
        path[1] = address(weth);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, 0, path, wallet, type(uint256).max);

        // Test WETH -> DTT
        weth.deposit{value: amountIn}();
        weth.approve(address(router), type(uint256).max);
        path[0] = address(weth);
        path[1] = address(dtt);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, 0, path, wallet, type(uint256).max);
    }

    function testSwapExactETHForTokensSupportingFeeOnTransferTokens() public {
        // Break down calculation into steps
        uint256 baseAmount = 10 * 10 ** 18;
        uint256 dttAmount = baseAmount * 100;
        dttAmount = dttAmount / 99; // Now it's a clean integer division

        uint256 ethAmount = 5 * 10 ** 18;
        uint256 swapAmount = 1 * 10 ** 18;

        addLiquidity(dttAmount, ethAmount);

        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(dtt);

        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: swapAmount}(0, path, wallet, type(uint256).max);
    }

    function testSwapExactTokensForETHSupportingFeeOnTransferTokens() public {
        // Break down calculation into steps
        uint256 baseAmount = 5 * 10 ** 18;
        uint256 dttAmount = baseAmount * 100;
        dttAmount = dttAmount / 99; // Now it's a clean integer division

        uint256 ethAmount = 10 * 10 ** 18;
        uint256 swapAmount = 1 * 10 ** 18;

        addLiquidity(dttAmount, ethAmount);
        dtt.approve(address(router), type(uint256).max);

        address[] memory path = new address[](2);
        path[0] = address(dtt);
        path[1] = address(weth);

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(swapAmount, 0, path, wallet, type(uint256).max);
    }

    receive() external payable {}
}
