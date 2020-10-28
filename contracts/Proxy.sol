// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

abstract contract Proxy {
    /**
    * @dev Tells the address of the implementation where every call will be delegated.
    * @return address of the implementation to which it will be delegated
    */
    function implementation() public virtual view returns (address);

    /**
    * @dev Fallback function allowing to perform a delegatecall to the given implementation.
    * This function will return whatever the implementation call returns
    */
    fallback() payable external {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
        // Copy msg.data. We take full control of memory in this inline assembly
        // block because it will not return to Solidity code. We overwrite the
        // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

        // Call the implementation.
        // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(
            gas(),
            _impl,
            0,
            calldatasize(),
            0,
            0
            )

        // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return (0, returndatasize())
            }
        }
    }
}