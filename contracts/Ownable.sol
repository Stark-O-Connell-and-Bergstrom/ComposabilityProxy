pragma solidity ^0.7.0;

import './BaseOwnable.sol';

contract Ownable is BaseOwnable {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    function setUpgradeabilityProxyOwner(address newProxyOwner) internal {
        bytes32 position = proxyOwnerPosition;
        assembly {
            sstore(position, newProxyOwner)
        }
    }

    function transferProxyOwnership(address newOwner) public onlyProxyOwner {
        require(newOwner != address(0));
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        setUpgradeabilityProxyOwner(newOwner);
    }
}
