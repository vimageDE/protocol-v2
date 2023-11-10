// SPDX-License-Identifier: ICT
pragma solidity 0.6.12;
import {ILendingPoolAddressesProvider} from '../../interfaces/ILendingPoolAddressesProvider.sol';
import {VersionedInitializable} from '../../protocol/libraries/aave-upgradeability/VersionedInitializable.sol';
import {LendingPoolStorage} from '../../protocol/lendingpool/LendingPoolStorage.sol';

contract MockProxyAddress is VersionedInitializable, LendingPoolStorage {
  uint256 public constant LENDINGPOOL_REVISION = 0x2;

  function initialize(ILendingPoolAddressesProvider provider) public initializer {
    _addressesProvider = provider;
    _maxStableRateBorrowSizePercent = 2500;
    _flashLoanPremiumTotal = 9;
    _maxNumberOfReserves = 128;
  }

  function getRevision() internal pure override returns (uint256) {
    return LENDINGPOOL_REVISION;
  }
}
