// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MockFeeContract {
  uint256 public fee;
  event FeesReceived(address indexed from, uint256 amount);

  constructor(uint256 _fee) public {
    fee = _fee;
  }

  function setGraceContract(bool enterGrace) external {}

  function updateFee() public {}

  function nextResetTime() public view returns (uint256) {
    // next reset time will always be a day in the future
    return (block.timestamp + 1 days);
  }

  function getFee() public view returns (uint256) {
    // Mock implementation
    return fee;
  }

  function queryOracle() public view returns (uint256) {
    // Mock implementation
    return getFee() + 100;
  }

  receive() external payable {
    emit FeesReceived(msg.sender, msg.value);
  }
}
