// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import './IFeeContract.sol';
import '../dependencies/openzeppelin/contracts/SafeMath.sol';

/**
 * @title H1NativeApplicationDowngraded
 * @author Haven1 Development Team
 * @notice This contract's purpose is to provide modifiers to functions that ensure fees are sent to the FeeContract.
 * @notice This contract is a downgraded version of H1NativeApplication.sol for compatibility with UniswapV2.
 * @dev The primary function of this contract is to be used as an import for application building on Haven1.
 */
contract H1NativeApplicationDowngraded {
  using SafeMath for uint;

  /* STATE VARIABLES
    ==================================================*/

  /**
   * @dev The fee contract address
   */
  address public _feeContract;

  /**
   * @dev The fee required to run transactions.
   */
  uint256 private _fee;

  /**
   * @dev The timestamp in which the `_fee` must update.
   */
  uint256 private _requiredFeeResetTime;

  /**
   * @dev The block number in which the fee was last updated.
   */
  uint256 private _resetBlock;

  /**
   * @dev The fee before the oracle updated.
   */
  uint256 private _priorFee;

  /**
   * @notice To be used in functions that take a fee that also need to call `msg.value`.
   * @dev msgValueAfterFee = msg.value - chargableFee.
   */
  uint256 public msgValueAfterFee;

  /* ERRORS
    ==================================================*/

  /**
   * @dev Error to inform the user that not enough funds have been sent to
   * the function.
   */

  // Custom Errors removed for downgrade to Solidity 0.6.6
  // error InsufficientFunds();

  /* MODIFIERS
    ==================================================*/

  /**
   * @dev Sends fees to the fee contract for non-payable functions.
   */
  modifier applicationFee() {
    if (_requiredFeeResetTime <= block.timestamp) {
      _updatesOracleValues();
      _payApplicationWithAdjustedFee();
    } else if (_resetBlock >= block.number) {
      _payApplicationWithAdjustedFee();
    } else {
      _payApplicationWithFee();
    }

    _;
  }

  /**
   * @dev Sends fees to the fee contract for payable functions.
   */
  modifier applicationFeeWithPayableFunction() {
    if (_requiredFeeResetTime <= block.timestamp) {
      _updatesOracleValues();
      _payApplicationWithAdjustedFeeAndContract();
    } else if (_resetBlock >= block.number) {
      _payApplicationWithAdjustedFeeAndContract();
    } else {
      _payApplicationWithFeeAndContract();
    }

    _;

    delete msgValueAfterFee;
  }

  /* FUNCTIONS
    ==================================================*/
  /* Constructor
    ========================================*/

  /**
   * @notice Constructor to initialize contract deployment.
   * @param feeContract Address of `FeeContract` to pay fees to and to obtain
   * network information from.
   */
  function H1NativeApplication_init(address feeContract) internal {
    _feeContract = feeContract;
    _requiredFeeResetTime = IFeeContract(_feeContract).nextResetTime();
    _fee = IFeeContract(_feeContract).queryOracle();
    _priorFee = IFeeContract(_feeContract).queryOracle();
    uint256 blockNumber = block.number;
    _resetBlock = blockNumber.sub(1);
  }

  /* Public
    ========================================*/

  /**
   * @notice Gets the fee amount from the `feeContract`.
   * @return Fee as `uint256`.
   *
   * @dev Returns the fee as a `uint256`. Fee is used in the `applicationFee`
   * modifier.
   */
  function callFee() public view returns (uint256) {
    return IFeeContract(_feeContract).queryOracle();
  }

  /* Internal
    ========================================*/

  /**
   * @notice Updates the state variables of this contract `FeeContract` if
   * applicable.
   *
   * @dev The information about the `fee` and `_requiredFeeResetTime` come
   * from the FeeContract.
   *
   * The `priorFee` is the fee before the oracle updates the `_fee` variable.
   *
   * The `_requiredFeeResetTime` is set equal to the `FeeContract`'s next
   * reset time.
   *
   * `_resetBlock` is set in this function to ensure that the fee for
   * transactions sent in the same block are handled correctly.
   */
  function _updatesOracleValues() internal {
    uint256 updatedResetTime = IFeeContract(_feeContract).nextResetTime();
    if (updatedResetTime == _requiredFeeResetTime) {
      IFeeContract(_feeContract).updateFee();
    }

    _priorFee = _fee;
    _fee = IFeeContract(_feeContract).queryOracle();

    _requiredFeeResetTime = IFeeContract(_feeContract).nextResetTime();

    uint256 blockNumber = block.number;
    _resetBlock = blockNumber.add(500);
  }

  /**
   * @notice Handles paying the applicaiton fee for transactions that occur
   * during the oracle reset period.
   *
   * @dev If there is an excess amount of H1, it is returned to the sender.
   *
   * It throws an `InsufficientFunds()` error if the received value is less
   * than the appropriate fee.
   */
  function _payApplicationWithAdjustedFee() internal {
    uint256 chargableFee = _priorFee;
    uint256 msgValue = msg.value;

    if (_fee <= _priorFee) {
      chargableFee = _fee;
    }

    if (msg.value < chargableFee) {
      revert('Insufficient Funds');
    }

    _feeContract.call{value: chargableFee}('');

    if (msgValue.sub(chargableFee) > 0) {
      uint256 overflow = (msgValue.sub(chargableFee));
      payable(msg.sender).call{value: overflow}('');
    }
  }

  /**
   * @notice Handles paying the application fee.
   *
   * @dev If there is an excess amount of H1 sent, it is returned to the sender.
   *
   * It throws an `InsufficientFunds()` error if the received value is less
   * than the appropriate fee.
   */
  function _payApplicationWithFee() internal {
    uint256 msgValue = msg.value;

    if (msg.value < _fee) {
      revert('InsufficientFunds');
    }

    _feeContract.call{value: _fee}('');

    if (msgValue.sub(_fee) > 0) {
      uint256 overflow = (msgValue.sub(_fee));
      payable(msg.sender).call{value: overflow}('');
    }
  }

  /**
   * @notice Handles paying the applicaiton fee for transactions that occur
   * during the oracle reset period for functions that require access to
   * `msg.value`.
   *
   * @dev If there is an excess amount of H1 sent, it is returned to the sender.
   *
   * This function handles setting the `msgValueAfterFee` so that it may be
   * used in places that originally would have required access to `msg.value`.
   * `msgValueAfterFee = msg.value - chargableFee;`
   *
   * It throws an `InsufficientFunds()` error if the received value is less
   * than the appropriate fee.
   */

  function _payApplicationWithAdjustedFeeAndContract() internal {
    uint256 chargableFee = _priorFee;
    uint256 msgValue = msg.value;

    if (_fee <= _priorFee) {
      chargableFee = _fee;
    }

    if (msg.value < chargableFee) {
      revert('Insufficient Funds');
    }

    _feeContract.call{value: chargableFee}('');

    msgValueAfterFee = msgValue.sub(chargableFee);
  }

  /**
   * @notice Handles paying the application fee for functions that require access to
   * `msg.value`.
   *
   * @dev If there is an excess amount of H1 sent, it is returned to the sender.
   *
   * This function handles setting the `msgValueAfterFee` so that it may be
   * used in places that originally would have required access to `msg.value`.
   * `msgValueAfterFee = msg.value - chargableFee;`
   *
   * It throws an `InsufficientFunds()` error if the received value is less
   * than the appropriate fee.
   */
  function _payApplicationWithFeeAndContract() internal {
    uint256 msgValue = msg.value;
    if (msg.value < _fee) {
      revert('Insufficient Funds');
    }
    _feeContract.call{value: _fee}('');
    msgValueAfterFee = msgValue.sub(_fee);
  }
}
