// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test} from "forge-std/Test.sol";
import {UniswapV2Factory} from "../src/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/UniswapV2Pair.sol";

contract UniswapV2FactoryTest is Test {
    UniswapV2Factory public factory;
    address public wallet = address(this);
    address public other = address(0x1);

    address public constant TEST_ADDR_1 = address(0x1000000000000000000000000000000000000000);
    address public constant TEST_ADDR_2 = address(0x2000000000000000000000000000000000000000);

    function setUp() public {
        factory = new UniswapV2Factory(wallet);
    }

    function testInitialState() public view {
        assertEq(factory.feeTo(), address(0));
        assertEq(factory.feeToSetter(), wallet);
        assertEq(factory.allPairsLength(), 0);
    }

    function testCreatePair() public {
        address pair = factory.createPair(TEST_ADDR_1, TEST_ADDR_2);

        assertEq(factory.getPair(TEST_ADDR_1, TEST_ADDR_2), pair);
        assertEq(factory.getPair(TEST_ADDR_2, TEST_ADDR_1), pair);
        assertEq(factory.allPairs(0), pair);
        assertEq(factory.allPairsLength(), 1);

        UniswapV2Pair pairContract = UniswapV2Pair(pair);
        assertEq(address(pairContract.factory()), address(factory));
        assertEq(pairContract.token0(), TEST_ADDR_1);
        assertEq(pairContract.token1(), TEST_ADDR_2);
    }

    function testCreatePairReverse() public {
        address pair = factory.createPair(TEST_ADDR_2, TEST_ADDR_1);

        assertEq(factory.getPair(TEST_ADDR_1, TEST_ADDR_2), pair);
        assertEq(factory.getPair(TEST_ADDR_2, TEST_ADDR_1), pair);

        UniswapV2Pair pairContract = UniswapV2Pair(pair);
        assertEq(pairContract.token0(), TEST_ADDR_1);
        assertEq(pairContract.token1(), TEST_ADDR_2);
    }

    function testCreatePairFailIdenticalAddresses() public {
        vm.expectRevert("UniswapV2: IDENTICAL_ADDRESSES");
        factory.createPair(TEST_ADDR_1, TEST_ADDR_1);
    }

    function testCreatePairFailZeroAddress() public {
        vm.expectRevert("UniswapV2: ZERO_ADDRESS");
        factory.createPair(TEST_ADDR_1, address(0));
    }

    function testCreatePairFailPairExists() public {
        factory.createPair(TEST_ADDR_1, TEST_ADDR_2);
        vm.expectRevert("UniswapV2: PAIR_EXISTS");
        factory.createPair(TEST_ADDR_1, TEST_ADDR_2);
    }

    function testSetFeeTo() public {
        factory.setFeeTo(other);
        assertEq(factory.feeTo(), other);
    }

    function testSetFeeToForbidden() public {
        vm.prank(other);
        vm.expectRevert("UniswapV2: FORBIDDEN");
        factory.setFeeTo(other);
    }

    function testSetFeeToSetter() public {
        factory.setFeeToSetter(other);
        assertEq(factory.feeToSetter(), other);

        vm.prank(wallet);
        vm.expectRevert("UniswapV2: FORBIDDEN");
        factory.setFeeToSetter(wallet);
    }
}
