// TestUtils.sol
pragma solidity ^0.8.0;

library TestUtils {
    // Define the snapLastCall function
    function snapLastCall(string memory name) public {
        // Implementation here
        // For example, you might log the name or store it in a mapping
        // This is just a placeholder implementation
    }

     function snapSize(string memory name, address contractAddress) public view returns (uint256) {
        // Implementation here
        // For example, you might retrieve the bytecode size of the contract at the given address
        bytes memory bytecode = address(contractAddress).code;
        return bytecode.length;
    }
}