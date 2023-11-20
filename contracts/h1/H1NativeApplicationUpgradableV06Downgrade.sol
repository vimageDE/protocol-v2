// SPDX-License-Identifier: ISC
pragma solidity ^0.6.0;

import './base/H1NativeBaseV06Downgrade.sol';

contract H1NativeApplicationUpgradableV06Downgrade is H1NativeBaseV06Downgrade {
  function initializeBase(address feeContract) internal {
    _h1NativeBase_init(feeContract);
  }
}
