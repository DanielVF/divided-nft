// SPDX-License-Identifier: MIT
// Author: Daniel Von Fange (@DanielVF)

pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/DividedPool.sol";
import "../src/DividedFactory.sol";
import "../src/DividedRouter.sol";
import "solmate/test/utils/mocks/MockERC721.sol";

contract DividedRouterTest is Test {
    DividedPool public pool;
    DividedFactory public factory;
    DividedRouter public router;
    MockERC721 public nft;

    address ALICE = address(0xA11CE);
    address BOB = address(0xB0BB);
    uint256 constant FULL_SHARDS = 100 * 1e18;

    function setUp() public {
        nft = new MockERC721("Rocket", "RKT");
        nft.mint(address(this), 1);
        nft.mint(ALICE, 2);
        nft.mint(BOB, 3);
        nft.mint(address(this), 4);

        factory = new DividedFactory();
        router = new DividedRouter(address(factory));

        pool = DividedPool(factory.deploy(address(nft)));

        nft.transferFrom(address(this), address(pool), 4);
        pool.swap(new uint256[](0), address(this), address(this));
    }

    function testNftIn() public {
        assertEq(pool.totalSupply(), FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), FULL_SHARDS);
        assertEq(nft.ownerOf(1), address(this));

        nft.approve(address(router), 1);
        router.nftIn(address(nft), 1, address(this));

        assertEq(pool.totalSupply(), 2 * FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), 2 * FULL_SHARDS);
        assertEq(nft.ownerOf(1), address(pool));
    }

    function testNftInNoSteal() public {
        assertEq(pool.totalSupply(), FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), FULL_SHARDS);
        assertEq(nft.ownerOf(1), address(this));

        nft.approve(address(router), 1);
        vm.prank(ALICE);
        vm.expectRevert();
        router.nftIn(address(nft), 1, address(this));
    }

    function testNftOut() public {
        pool.approve(address(router), FULL_SHARDS);
        router.nftOut(address(nft), 4, address(this));
        assertEq(nft.ownerOf(4), address(this));
        assertEq(pool.balanceOf(address(this)), 0);
        assertEq(pool.totalSupply(), 0);
    }

    function testNftOutNoSteal() public {
        pool.approve(address(router), FULL_SHARDS);
        vm.prank(ALICE);
        vm.expectRevert();
        router.nftOut(address(nft), 4, address(this));
    }

    function testSwap() public {
        nft.approve(address(router), 1);
        router.nftSwap(address(nft), 1, 4, address(this));

        assertEq(nft.ownerOf(4), address(this), "NFT out");
        assertEq(nft.ownerOf(1), address(pool), "NFT in");
        assertEq(pool.balanceOf(address(this)), FULL_SHARDS);
    }

    function testBatchNftIn() public {
        nft.mint(address(this), 5);

        assertEq(pool.totalSupply(), FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), FULL_SHARDS);
        assertEq(nft.ownerOf(1), address(this));

        uint256[] memory ids = new uint256[](2);
        ids[0] = 1;
        ids[1] = 5;
        nft.approve(address(router), 1);
        nft.approve(address(router), 5);
        router.batchNftIn(address(nft), ids, address(this));

        assertEq(pool.totalSupply(), 3 * FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), 3 * FULL_SHARDS);
        assertEq(nft.ownerOf(1), address(pool));
        assertEq(nft.ownerOf(5), address(pool));
    }

    function testBatchNftOut() public {
        nft.mint(address(this), 5);
        nft.approve(address(router), 5);
        router.nftIn(address(nft), 5, address(this));

        uint256[] memory ids = new uint256[](2);
        ids[0] = 4;
        ids[1] = 5;
        pool.approve(address(router), 2 * FULL_SHARDS);
        router.batchNftOut(address(nft), ids, address(this));

        assertEq(pool.totalSupply(), 0 * FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), 0 * FULL_SHARDS);
        assertEq(nft.ownerOf(4), address(this));
        assertEq(nft.ownerOf(5), address(this));
    }

    function testBatchSwap() public {
        nft.mint(address(this), 5);
        nft.approve(address(router), 5);
        router.nftIn(address(nft), 5, address(this));

        nft.mint(address(this), 6);
        nft.approve(address(router), 6);
        nft.approve(address(router), 1);

        uint256[] memory ins = new uint256[](2);
        ins[0] = 6;
        ins[1] = 1;
        uint256[] memory outs = new uint256[](2);
        outs[0] = 5;
        outs[1] = 4;
        pool.approve(address(router), 2 * FULL_SHARDS);
        router.batchNftSwap(address(nft), ins, outs, address(this));

        assertEq(pool.totalSupply(), 2 * FULL_SHARDS);
        assertEq(pool.balanceOf(address(this)), 2 * FULL_SHARDS);
        assertEq(nft.ownerOf(4), address(this));
        assertEq(nft.ownerOf(5), address(this));
    }

    function testPools(address i) public {
        address nftCollection = address(new MockERC721("Rocket", "RKT"));
        address deployed = factory.deploy(nftCollection);
        address calculated = router.pools(nftCollection);
        assertEq(deployed, calculated);
        vm.expectRevert();
        factory.deploy(nftCollection);
    }
}
