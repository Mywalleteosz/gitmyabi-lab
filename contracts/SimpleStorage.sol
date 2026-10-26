// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

contract SimpleStorage {
    uint256 private storedValue;

    function get() external view returns (uint256) {
        return storedValue;
    }

    function set(uint256 value) external {
        storedValue = value;
    }
}
