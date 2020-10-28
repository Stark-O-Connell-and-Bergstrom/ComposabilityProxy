# ComposabilityProxy
The ComposabilityProxy allows developers to compose multiple versions of their contract out of multiple logic contracts and libraries, providing greater flexibility and reduced gas costs when deploying and upgrading contracts.

The full functionality of the proxy:
- Ownability - initial owner is set in the constructor and can be transferred at any point by the owner.
- Upgradability - contract can be upgraded by the owner while keeping its address.
- Versioning - manage multiple version labels, each can be mapped to different contract addresses.
- Composability - map function signatures to implementation address, allowing each version label to be independent and map its own functions while having a fallback implementation address for unmapped functions.

# Behaviour
The proxy consists of a mapping of string labels to Version structs, each Version consists of a defaultImplementation address, and a mapping of bytes4 function signatures to function implementation address.
Upon construction of the proxy, a 'DEFAULT' label is created with the input defaultImplementation address as its defaultImplementation.
The owner can add/remove labels completely or map/unmap specific function signatures to a different implementation address per label by calling setLabelVersion. removing/unmapping is done by setting the address to address(0).

any account can use any label by calling useVersionLabel, any future calls by this account will be proxied to the corresponding version until explicitly changed (by calling useVersionLabel again), or the label is removed by the owner. if the label is removed the calls will be proxied to the 'DEFAULT' label.

Upon call, the proxy will look for the version used by the calling account (if not explicitly set, the user will be proxied to the 'DEFAULT' version), then it will look for the called function signature in the mapping and proxy the call to the corresponding address. if the function is unmapped it will fallback to the version defaultImplementation.

# Usage
```solidity
constructor(address defaultImpl, address owner)
```
- `defaultImpl` - the default logic contract, will be set as the defaultImplementation of the 'DEFAULT' label.
- `owner` - the address to give proxy ownership to.

```solidity
setLabelVersion(string label, address[] targets, bytes4[] signatures, bool setDefaultImpl)
```
- `label` - the name of the label.
- `targets` - list of addresses corresponding to the signatures param. min size 1.
- `signatures` - list of bytes4 encoded function signatures corresponding to the targets param. min size 0.
- `setDefaultImpl` - when set to true it will override defaultImplementation of the version with the address in targets[0].

##### setLabelVersion is used for all label version manipulation as follows
- Add label - a label will be added when the input "label" is not yet defined. when adding a new label the address in targets[0] will be used as the defaultImplementation for the version (the value of setDefaultImpl will be considered true when adding a new label). functions can be mapped to other addresses in the same tx.

- Remove label - to fully remove the label "targets" must have a single value of address(0) and signatures must be an empty array (otherwise it will remove only the function mapping)

- Map/Unmap functions - each signature in "signatures" will be mapped to the corresponding target in "targets". to unmap pass address(0) in the correct place in "targets".

- Update defaultImplementation - can be done in any Map/Unmap action by passing setDefaultImpl=true, which will set the address in targets[0] as the defaultImplementation. if no mapping/unmapping is required, updating defaultImplementation can be done by passing a single target in "targets" and an empty "signatures" array (the value of setDefaultImpl will be considered true in this case)

```solidity
useVersionLabel(string label)
```
- label - the name of the label to be used in future calls by msg.sender
