pragma solidity ^0.7.0;

contract VersionMap {

    struct Version {
        mapping(bytes4 => address) functionMap;
        address defaultImplementation;
    }

    mapping(string => Version) versionMap;

    mapping(address => string) userToLabel;

    event LabelVersionSet(string label, address[] targets, bytes4[] signatures, bool setDefaultImpl);

    event LabelVersionRemoved(string label);

    event UserLabelSet(string label, address user);

    function hasLabel(string memory label) internal returns (bool) {
        return versionMap[label].defaultImplementation != address(0);
    }

    function getUserVersionLabel() public view returns (string memory) {
        return userToLabel[msg.sender];
    }
}
