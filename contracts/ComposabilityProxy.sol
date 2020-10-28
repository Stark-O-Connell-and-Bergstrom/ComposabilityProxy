pragma solidity ^0.7.0;

import './Proxy.sol';
import './Ownable.sol';
import './VersionMap.sol';

contract ComposabilityProxy is VersionMap, Ownable, Proxy {

    constructor() {
        setUpgradeabilityProxyOwner(msg.sender);
    }

    function initProxy(address defaultImpl, address owner) public onlyProxyOwner {
        require(!hasLabel('DEFAULT'), 'already initialized');

        bytes4[] memory signatures = new bytes4[](0);
        address[] memory targets = new address[](1);
        targets[0] = defaultImpl;
        setLabelVersion('DEFAULT', targets, signatures, true);
        setUpgradeabilityProxyOwner(owner);
    }

    function implementation() public override view returns (address) {
        string memory useLabel = userToLabel[tx.origin];

        Version storage version = versionMap[useLabel];
        if (version.defaultImplementation == address(0)) {
            version = versionMap['DEFAULT'];
        }

        address impl = version.functionMap[msg.sig];
        if (impl == address(0)) {
            impl = version.defaultImplementation;
        }

        return impl;
    }

    function setLabelVersion(string memory label, address[] memory targets, bytes4[] memory signatures, bool setDefaultImpl) public onlyProxyOwner {
        require(targets.length > 0, "must contain at least one target");

        bool singleTargetOnly = targets.length == 1 && signatures.length == 0;
        if (singleTargetOnly && targets[0] == address(0)) {
            // remove the entire label
            versionMap[label].defaultImplementation = address(0);

            emit LabelVersionRemoved(label);
        }
        else {
            require(singleTargetOnly || targets.length == signatures.length, "targets and signatures must have the same size");
            Version storage version = versionMap[label];
            if (setDefaultImpl || version.defaultImplementation == address(0)) {
                // new label - set targets[0] as the default implementation
                version.defaultImplementation = targets[0];
            }
            // set or remove functions from map (remove if impl == address(0))
            for (uint i = 0; i < signatures.length; i++) {
                version.functionMap[signatures[i]] = targets[i];
            }

            emit LabelVersionSet(label, targets, signatures, setDefaultImpl);
        }
    }

    function useVersionLabel(string memory label) public {
        require(hasLabel(label), 'unknown label');
        userToLabel[msg.sender] = label;

        emit UserLabelSet(label, msg.sender);
    }
}
