pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Router02} from "../src/periphery/UniswapV2Router.sol";
import {WETH9} from "../src/test/WETH9.sol";
import {ERC20} from "../src/test/ERC20.sol";
import {Utilities} from "./shared/Utilities.sol";

contract UniswapV2RouterTest is Test {
    using Utilities for uint256;

    UniswapV2Factory public factory;
    UniswapV2Router02 public router;
    ERC20 public token0;
    ERC20 public token1;
    WETH9 public weth;
    address public wallet = address(this);

    uint256 public constant MAX_UINT = type(uint256).max;
    uint256 public constant MINIMUM_LIQUIDITY = 10 ** 3;

    function setUp() public {
        weth = new WETH9();
        factory = new UniswapV2Factory(wallet);
        router = new UniswapV2Router02(address(factory), address(weth));
        token0 = new ERC20(10000 * 10 ** 18);
        token1 = new ERC20(10000 * 10 ** 18);
    }

    function testQuote() public {
        assertEq(router.quote(1, 100, 200), 2);
        assertEq(router.quote(2, 200, 100), 1);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_AMOUNT");
        router.quote(0, 100, 200);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        router.quote(1, 0, 200);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        router.quote(1, 100, 0);
    }

    function testGetAmountOut() public {
        assertEq(router.getAmountOut(2, 100, 100), 1);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        router.getAmountOut(0, 100, 100);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        router.getAmountOut(2, 0, 100);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        router.getAmountOut(2, 100, 0);
    }

    function testGetAmountIn() public {
        assertEq(router.getAmountIn(1, 100, 100), 2);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        router.getAmountIn(0, 100, 100);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        router.getAmountIn(1, 0, 100);

        vm.expectRevert("UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        router.getAmountIn(1, 100, 0);
    }

    function testGetAmountsOut() public {
        token0.approve(address(router), MAX_UINT);
        token1.approve(address(router), MAX_UINT);

        router.addLiquidity(address(token0), address(token1), 10000, 10000, 0, 0, wallet, MAX_UINT);

        address[] memory path = new address[](1);
        path[0] = address(token0);
        vm.expectRevert("UniswapV2Library: INVALID_PATH");
        router.getAmountsOut(2, path);

        path = new address[](2);
        path[0] = address(token0);
        path[1] = address(token1);
        uint256[] memory amounts = router.getAmountsOut(2, path);
        assertEq(amounts[0], 2);
        assertEq(amounts[1], 1);
    }

    function testGetAmountsIn() public {
        token0.approve(address(router), MAX_UINT);
        token1.approve(address(router), MAX_UINT);

        router.addLiquidity(address(token0), address(token1), 10000, 10000, 0, 0, wallet, MAX_UINT);

        address[] memory path = new address[](1);
        path[0] = address(token0);
        vm.expectRevert("UniswapV2Library: INVALID_PATH");
        router.getAmountsIn(1, path);

        path = new address[](2);
        path[0] = address(token0);
        path[1] = address(token1);
        uint256[] memory amounts = router.getAmountsIn(1, path);
        assertEq(amounts[0], 2);
        assertEq(amounts[1], 1);
    }
}
