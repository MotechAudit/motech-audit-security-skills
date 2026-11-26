// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/VulnerableCappedMint.sol";
import "../src/FixedCappedMint.sol";

/// @dev A separate caller used to prove that mint authorization is unchanged.
contract NonOwnerMinter {
    function mintVulnerable(VulnerableCappedMint token, uint256 amount) external returns (bool) {
        (bool ok,) = address(token).call(
            abi.encodeWithSelector(VulnerableCappedMint.mint.selector, amount)
        );
        return ok;
    }

    function mintFixed(FixedCappedMint token, uint256 amount) external returns (bool) {
        (bool ok,) = address(token).call(
            abi.encodeWithSelector(FixedCappedMint.mint.selector, amount)
        );
        return ok;
    }
}

contract InputValidationTest {
    uint256 private constant MAX_SUPPLY = 100;

    function testOwnerCanMintBelowCapInBothFixtures() public {
        VulnerableCappedMint vulnerable = new VulnerableCappedMint(MAX_SUPPLY);
        FixedCappedMint fixedToken = new FixedCappedMint(MAX_SUPPLY);

        vulnerable.mint(40);
        fixedToken.mint(40);

        require(vulnerable.totalSupply() == 40, "vulnerable below-cap mint failed");
        require(fixedToken.totalSupply() == 40, "fixed below-cap mint failed");
    }

    function testFixedFixtureCanMintExactlyToCap() public {
        FixedCappedMint token = new FixedCappedMint(MAX_SUPPLY);

        token.mint(60);
        token.mint(40);

        require(token.totalSupply() == MAX_SUPPLY, "exact-cap mint failed");
        require(token.balanceOf(address(this)) == MAX_SUPPLY, "owner balance mismatch");
    }

    function testSingleMintAboveCapRevertsInFixedFixture() public {
        FixedCappedMint token = new FixedCappedMint(MAX_SUPPLY);

        (bool ok,) = address(token).call(
            abi.encodeWithSelector(FixedCappedMint.mint.selector, MAX_SUPPLY + 1)
        );

        require(!ok, "fixed fixture allowed a mint above the cap");
        require(token.totalSupply() == 0, "reverted mint changed total supply");
    }

    function testRepeatedMintsCannotExceedCapInFixedFixture() public {
        FixedCappedMint token = new FixedCappedMint(MAX_SUPPLY);

        token.mint(60);
        (bool ok,) = address(token).call(
            abi.encodeWithSelector(FixedCappedMint.mint.selector, 41)
        );

        require(!ok, "fixed fixture allowed repeated mints above the cap");
        require(token.totalSupply() == 60, "reverted second mint changed supply");
        require(token.totalSupply() <= token.maxSupply(), "supply invariant violated");
    }

    function testVulnerableFixtureDemonstratesMissingCapCheck() public {
        VulnerableCappedMint token = new VulnerableCappedMint(MAX_SUPPLY);

        token.mint(60);
        token.mint(50);

        require(token.totalSupply() == 110, "vulnerable fixture did not reproduce over-mint");
        require(token.totalSupply() > token.maxSupply(), "expected supply to exceed declared cap");
    }

    function testNonOwnerCannotMintInEitherFixture() public {
        VulnerableCappedMint vulnerable = new VulnerableCappedMint(MAX_SUPPLY);
        FixedCappedMint fixedToken = new FixedCappedMint(MAX_SUPPLY);
        NonOwnerMinter attacker = new NonOwnerMinter();

        require(!attacker.mintVulnerable(vulnerable, 1), "non-owner minted vulnerable fixture");
        require(!attacker.mintFixed(fixedToken, 1), "non-owner minted fixed fixture");
        require(vulnerable.totalSupply() == 0, "unauthorized vulnerable mint changed supply");
        require(fixedToken.totalSupply() == 0, "unauthorized fixed mint changed supply");
    }

    function testZeroAmountRejectedInBothFixtures() public {
        VulnerableCappedMint vulnerable = new VulnerableCappedMint(MAX_SUPPLY);
        FixedCappedMint fixedToken = new FixedCappedMint(MAX_SUPPLY);

        (bool vulnerableOk,) = address(vulnerable).call(
            abi.encodeWithSelector(VulnerableCappedMint.mint.selector, 0)
        );
        (bool fixedOk,) = address(fixedToken).call(
            abi.encodeWithSelector(FixedCappedMint.mint.selector, 0)
        );

        require(!vulnerableOk, "vulnerable fixture accepted zero mint");
        require(!fixedOk, "fixed fixture accepted zero mint");
    }
}
