//SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

interface IFeeContract {
  // This function retrieves the value of H1 in USD.
  function queryOracle() external view returns (uint256);

  //This function returns a timestamp that will tell the contract when to update the oracle.
  function nextResetTime() external view returns (uint256);

  // This function updates the fees in the fee contract to match the oracle values.
  function updateFee() external;
}
