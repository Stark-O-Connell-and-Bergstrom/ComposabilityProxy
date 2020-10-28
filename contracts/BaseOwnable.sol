pragma solidity ^0.7.0;

contract BaseOwnable {
    bytes32 internal constant proxyOwnerPosition = keccak256("composability.proxy.owner");

    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner(), "not owner");
        _;
    }

    function proxyOwner() public view returns (address owner) {
        bytes32 position = proxyOwnerPosition;
        assembly {
            owner := sload(position)
        }
    }

}
