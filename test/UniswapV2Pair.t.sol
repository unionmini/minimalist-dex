// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "forge-std/Test.sol";
import "../src/UniswapV2Pair.sol";
import "../src/UniswapV2Factory.sol";
import "./mocks/ERC20.sol";

contract UniswapV2PairTest is Test {
    UniswapV2Factory factory;
    ERC20 token0;
    ERC20 token1;
    UniswapV2Pair pair;

    address wallet = address(this);
    address other = address(0x1);

    uint256 constant MINIMUM_LIQUIDITY = 10 ** 3;

    function setUp() public {
        factory = new UniswapV2Factory(wallet);
        token0 = new ERC20(10000 * 10 ** 18);
        token1 = new ERC20(10000 * 10 ** 18);

        // Create pair
        factory.createPair(address(token0), address(token1));
        pair = UniswapV2Pair(factory.getPair(address(token0), address(token1)));
    }

    function testMint() public {
        uint112 token0Amount = 1 * 10 ** 18;
        uint112 token1Amount = 4 * 10 ** 18;

        token0.transfer(address(pair), token0Amount);
        token1.transfer(address(pair), token1Amount);

        uint256 expectedLiquidity = 2 * 10 ** 18;

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), address(0), MINIMUM_LIQUIDITY);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), wallet, expectedLiquidity - MINIMUM_LIQUIDITY);

        vm.expectEmit(true, true, true, true);
        emit Sync(token0Amount, token1Amount);

        vm.expectEmit(true, true, true, true);
        emit Mint(wallet, token0Amount, token1Amount);

        pair.mint(wallet);

        assertEq(pair.totalSupply(), expectedLiquidity);
        assertEq(pair.balanceOf(wallet), expectedLiquidity - MINIMUM_LIQUIDITY);
        assertEq(token0.balanceOf(address(pair)), token0Amount);
        assertEq(token1.balanceOf(address(pair)), token1Amount);

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        assertEq(reserve0, token0Amount);
        assertEq(reserve1, token1Amount);
    }

    function addLiquidity(uint256 token0Amount, uint256 token1Amount) internal {
        token0.transfer(address(pair), token0Amount);
        token1.transfer(address(pair), token1Amount);
        pair.mint(wallet);
    }

    function testSwap() public {
        uint256 token0Amount = 5 * 10 ** 18;
        uint256 token1Amount = 10 * 10 ** 18;
        addLiquidity(token0Amount, token1Amount);

        uint256 swapAmount = 1 * 10 ** 18;
        uint256 expectedOutputAmount = 1662497915624478906;

        token0.transfer(address(pair), swapAmount);

        vm.expectEmit(true, true, true, true);
        emit Swap(wallet, swapAmount, 0, 0, expectedOutputAmount, wallet);

        pair.swap(0, expectedOutputAmount, wallet, "");

        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        assertEq(reserve0, token0Amount + swapAmount);
        assertEq(reserve1, token1Amount - expectedOutputAmount);
        assertEq(token0.balanceOf(address(pair)), token0Amount + swapAmount);
        assertEq(token1.balanceOf(address(pair)), token1Amount - expectedOutputAmount);
    }

    function testBurn() public {
        uint256 token0Amount = 3 * 10 ** 18;
        uint256 token1Amount = 3 * 10 ** 18;
        addLiquidity(token0Amount, token1Amount);

        uint256 expectedLiquidity = 3 * 10 ** 18;
        pair.transfer(address(pair), expectedLiquidity - MINIMUM_LIQUIDITY);

        vm.expectEmit(true, true, true, true);
        emit Transfer(address(pair), address(0), expectedLiquidity - MINIMUM_LIQUIDITY);

        vm.expectEmit(true, true, true, true);
        emit Burn(wallet, token0Amount - 1000, token1Amount - 1000, wallet);

        pair.burn(wallet);

        assertEq(pair.balanceOf(wallet), 0);
        assertEq(pair.totalSupply(), MINIMUM_LIQUIDITY);
        assertEq(token0.balanceOf(address(pair)), 1000);
        assertEq(token1.balanceOf(address(pair)), 1000);
    }

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
