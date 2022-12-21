// // SPDX-License-Identifier: MIT
// // Author: Daniel Von Fange (@DanielVF)

// pragma solidity ^0.8.16;

// import "forge-std/Test.sol";
// import "../src/DividedPool.sol";
// import "../src/DividedFactory.sol";
// import "solmate/test/utils/mocks/MockERC721.sol";

// contract DividedTest is Test {
//     DividedPool public pool;
//     DividedFactory public factory;
//     MockERC721 public nft;

//     address ALICE = address(0xA11CE);
//     address BOB = address(0xB0BB);
//     uint256 constant FULL_SHARDS = 100 * 1e18;

//     function setUp() public {
//         nft = new MockERC721("Rocket", "RKT");
//         nft.mint(address(this), 1);
//         nft.mint(ALICE, 2);
//         nft.mint(address(this), 3);

//         factory = new DividedFactory();

//         pool = DividedPool(factory.deploy(address(nft)));

//         nft.approve(address(pool), 3);
//         pool.nftIn(3);
//     }

//     function testFactoryPoolStore() public {
//         assertEq(address(pool), factory.pools(address(nft)));
//     }

//     function testDoubleDeploy() public {
//         address aNFT = address(new MockERC721("RocketA", "RKTA"));
//         address bNFT = address(new MockERC721("RocketB", "RKTB"));
//         address a = factory.deploy(aNFT);
//         address b = factory.deploy(bNFT);
//         assert(a != b);
//     }

//     function testNftIn() public {
//         assertEq(pool.totalSupply(), FULL_SHARDS);
//         assertEq(pool.balanceOf(address(this)), FULL_SHARDS);
//         assertEq(nft.ownerOf(1), address(this));

//         nft.approve(address(pool), 1);
//         pool.nftIn(1);

//         assertEq(pool.totalSupply(), 2 * FULL_SHARDS);
//         assertEq(pool.balanceOf(address(this)), 2 * FULL_SHARDS);
//         assertEq(nft.ownerOf(1), address(pool));
//     }

//     function testNftOut() public {
//         pool.nftOut(3);
//         assertEq(nft.ownerOf(3), address(this));

//         vm.expectRevert();
//         pool.nftOut(2);
//     }

//     function testSwap() public {
//         nft.approve(address(pool), 1);
//         pool.swap(1, 3);
//         assertEq(nft.ownerOf(1), address(pool));
//         assertEq(nft.ownerOf(3), address(this));

//         nft.approve(address(pool), 3);
//         vm.expectRevert();
//         pool.swap(3, 2);
//     }

//     function testSweep() public {
//         assertEq(nft.ownerOf(3), address(pool));
//         vm.expectRevert();
//         pool.sweep(3);

//         vm.prank(ALICE);
//         nft.transferFrom(ALICE, address(pool), 2);
//         pool.sweep(2);

//         vm.expectRevert();
//         pool.sweep(3);
//     }
// }
