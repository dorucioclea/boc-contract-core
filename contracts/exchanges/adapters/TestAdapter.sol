// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "../IExchangeAdapter.sol";
import "../../library/NativeToken.sol";
import "../../price-feeds/IValueInterpreter.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

/// @title TestAdapter
/// @author Bank of Chain Protocol Inc
contract TestAdapter is IExchangeAdapter {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    address private valueInterpreter;

    constructor(address _valueInterpreter) {
        valueInterpreter = _valueInterpreter;
    }

    receive() external payable {}
    fallback() external payable {}

    /// @inheritdoc IExchangeAdapter
    function identifier() external pure override returns (string memory) {
        return "testAdapter";
    }

    /// @inheritdoc IExchangeAdapter
    function swap(
        uint8 _method,
        bytes calldata _encodedCallArgs,
        IExchangeAdapter.SwapDescription calldata _sd
    ) external payable override returns (uint256) {
        // Estimate how many target coins can be exchanged
        uint256 _amount = IValueInterpreter(valueInterpreter).calcCanonicalAssetValue(
            _sd.srcToken,
            _sd.amount,
            _sd.dstToken
        );
        // Mock exchange
        uint256 _expectAmount = (_amount * 1000) / 1000;
        if (_sd.dstToken == NativeToken.NATIVE_TOKEN) {
            payable(_sd.receiver).transfer(_expectAmount);
        } else {
            IERC20Upgradeable(_sd.dstToken).safeTransfer(_sd.receiver, _expectAmount);
        }
        return _expectAmount;
    }
}
