// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

/**
 * @title IFeeContract
 * @dev The interface for the FeeContract
 */
interface IFeeContract {
  /**
   * @notice Returns the timestamp for when the oracle can next update.
   * @return Timestamp for when the oracle can next update.
   */
  function nextResetTime() external view returns (uint256);

  /**
   * @notice Returns the fee amount an address should receive.
   * @param index The index in the array of channels/weights.
   * @return The intended fee.
   */
  function amountPaidToUponNextDistribution(uint8 index) external view returns (uint256);

  /**
   * @notice Returns the `_fee`.
   * @return The current fee.
   */
  function getFee() external view returns (uint256);

  /**
   * @notice Updates the fee in the fee contract to match the oracle value.
   */
  function updateFee() external;

  /**
   * @notice Returns all channels.
   * @return The channels.
   */
  function getChannels() external view returns (address[] memory);

  /**
   * @notice Return all the weights.
   * @return The weights.
   */
  function getWeights() external view returns (uint256[] memory);

  /**
   * @notice Returns the fee oracle address.
   * @return The fee oracle address.
   */
  function getOracleAddress() external view returns (address);

  /**
   * @notice Returns a channel's address and its weight.
   * @param index The index in the array of channels/weights.
   * @return The channel's address and its weight.
   */
  function getChannelWeightByIndex(uint8 index) external view returns (address, uint256);

  /**
   * @notice Returns the contract shares.
   * @return The contract shares.
   */
  function getTotalContractShares() external view returns (uint256);

  /**
   * @notice Returns the block timestamp that the most recent fee distribution occurred.
   * @return The timestamp of the most recent fee distribution.
   */
  function getLastDistribution() external view returns (uint256);

  /**
   * @notice Returns the min multiple on the fee that devs are allowed to charge.
   * @return The min multiple on the fee devs are allowed to charge.
   */
  function getMinDevFeeMultiple() external view returns (uint256);

  /**
   * @notice Returns the max multiple on the fee that devs are allowed to charge.
   * @return The max multiple on the fee devs are allowed to charge.
   */
  function getMaxDevFeeMultiple() external view returns (uint256);

  /**
   * @notice Returns the min fee that devs are allowed to charge.
   * @return The min fee devs are allowed to charge.
   */
  function getMinimumAllottedFee() external view returns (uint256);

  /**
   * @notice Returns the max fee that devs are allowed to charge.
   * @return The max fee devs are allowed to charge.
   */
  function getMaximumAllottedFee() external view returns (uint256);

  /**
   * @notice Returns the current fee, denominated in USD.
   * @return The fee, denominated in USD.
   */
  function queryOracle() external view returns (uint256);

  /**
   * @notice Distributes fees to channels.
   */
  function distributeFees() external;

  /**
   * @notice Forces a fee distribution.
   */
  function forceDistributeFees() external;

  /**
   * @notice Sets the minimum fee multiple for developer applications.
   *
   * @param multiple The minimum multiple of the base application fee that a
   * developer may charge.
   */
  function setMinFee(uint256 multiple) external;

  /**
   * @notice Sets the maximum fee multiple for developer applications.
   *
   * @param multiple The highest multiple of the base application fee that a
   * developer may charge.
   */
  function setMaxFee(uint256 multiple) external;

  /**
   * @notice Sets the oracle address.
   * @param newOracle The new oracle address.
   */
  function setOracle(address newOracle) external;

  /**
   * @notice Adds a new channel with a given weight.
   * @param _newChannelAddress The new channel to add.
   * @param _weight The weight for the new channel.
   */
  function addChannel(address _newChannelAddress, uint256 _weight) external;

  /**
   * @notice Adjusts a channel and its weight.
   * @param _oldChannelAddress The address of the channel to update.
   * @param _newChannelAddress The address of the channel that replaces the old one.
   * @param _newWeight The amount of total shares the new address will receive.
   */
  function adjustChannel(
    address _oldChannelAddress,
    address _newChannelAddress,
    uint256 _newWeight
  ) external;

  /**
   * @notice Removes a channel and it's weight.
   * @param _channel The address being removed.
   */
  function removeChannel(address _channel) external;

  /**
   * @notice set contracts that accesses grace fee.
   */
  function setGraceContract(bool enterGrace) external;

  /**
   * @notice enables admins to update the grace period.
   * @param gracePeriod the new grace period in seconds.
   */
  function setGracePeriod(uint256 gracePeriod) external;
}
