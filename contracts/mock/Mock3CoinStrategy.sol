// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "../strategy/BaseStrategy.sol";

contract MockS3CoinStrategy is BaseStrategy {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize(address _vault, address _harvester) public initializer {
        address[] memory _wants = new address[](3);
        // USDT
        _wants[0] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        // USDC
        _wants[1] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        // DAI
        _wants[2] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        super._initialize(_vault, _harvester, "MockS3CoinStrategy", 23, _wants);
    }

    function getVersion() external pure virtual override returns (string memory) {
        return "0.0.1";
    }

    function getWantsInfo()
        external
        view
        virtual
        override
        returns (address[] memory _assets, uint256[] memory _ratios)
    {
        _assets = wants;

        _ratios = new uint256[](3);
        _ratios[0] = 10**IERC20MetadataUpgradeable(wants[0]).decimals() * 1;
        _ratios[1] = 10**IERC20MetadataUpgradeable(wants[1]).decimals() * 2;
        _ratios[2] = 10**IERC20MetadataUpgradeable(wants[2]).decimals() * 4;
    }

    function getOutputsInfo() external view virtual override returns (OutputInfo[] memory _outputsInfo) {
        _outputsInfo = new OutputInfo[](1);
        OutputInfo memory _info = _outputsInfo[0];
        _info.outputCode = 0;
        _info.outputTokens = new address[](3);
        _info.outputTokens[0] = wants[0];
        _info.outputTokens[1] = wants[1];
        _info.outputTokens[2] = wants[2];
    }

    /// @notice Returns the position details of the strategy.
    function getPositionDetail()
        public
        view
        virtual
        override
        returns (
            address[] memory _tokens,
            uint256[] memory _amounts,
            bool isUsd,
            uint256 usdValue
        )
    {
        _tokens = new address[](wants.length);
        _amounts = new uint256[](_tokens.length);
        for (uint256 i = 0; i < _tokens.length; i++) {
            _tokens[i] = wants[i];
            _amounts[i] = IERC20Upgradeable(_tokens[i]).balanceOf(address(this));
        }
    }

    function get3rdPoolAssets() external view virtual override returns (uint256) {
        return type(uint256).max;
    }

    function getPendingRewards()
        public
        view
        virtual
        returns (address[] memory _rewardsTokens, uint256[] memory _pendingAmounts)
    {
        _rewardsTokens = new address[](0);
        _pendingAmounts = new uint256[](0);
    }

    function claimRewards()
        internal
        virtual
        returns (address[] memory _rewardsTokens, uint256[] memory _claimAmounts)
    {
        _rewardsTokens = new address[](0);
        _claimAmounts = new uint256[](0);
    }

    function depositTo3rdPool(address[] memory _assets, uint256[] memory _amounts)
        internal
        virtual
        override
    {
        for (uint256 i = 0; i < _assets.length; i++) {
            uint256 _amount = _amounts[i] / 1000;
            if (_amount > 0) {
                IERC20Upgradeable(_assets[i]).safeTransfer(harvester, _amount);
            }
        }
    }

    function withdrawFrom3rdPool(
        uint256 _withdrawShares,
        uint256 _totalShares,
        uint256 _outputCode
    ) internal virtual override {}
}
