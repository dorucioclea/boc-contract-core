// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title IDerivativePriceFeed Interface
/// @author Enzyme Council <security@enzyme.finance>
/// @notice Simple interface for derivative price source oracle implementations
interface IDerivativePriceFeed {
    function calcUnderlyingValues(address, uint256)
    external view
    returns (address[] memory, uint256[] memory);

    function isSupportedAsset(address) external view returns (bool);
}
