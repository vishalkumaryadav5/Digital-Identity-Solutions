// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Digital Identity Solutions
 * @dev A blockchain-based digital identity management system
 * @author Your Name
 */
contract DigitalIdentitySolutions {
    
    // Structure to store user identity information
    struct Identity {
        string name;
        string email;
        bool isVerified;
        uint256 createdAt;
        address verifier;
        string[] credentials;
    }
    
    // Mapping from user address to their identity
    mapping(address => Identity) private identities;
    
    // Mapping to track verified addresses
    mapping(address => bool) public isRegistered;
    
    // Mapping for authorized verifiers
    mapping(address => bool) public authorizedVerifiers;
    
    // Contract owner
    address public owner;
    
    // Events
    event IdentityCreated(address indexed user, string name, uint256 timestamp);
    event IdentityVerified(address indexed user, address indexed verifier, uint256 timestamp);
    event CredentialAdded(address indexed user, string credential, uint256 timestamp);
    event VerifierAuthorized(address indexed verifier, uint256 timestamp);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender], "Only authorized verifiers can perform this action");
        _;
    }
    
    modifier onlyRegistered() {
        require(isRegistered[msg.sender], "User must be registered");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        authorizedVerifiers[msg.sender] = true; // Owner is automatically a verifier
    }
    
    /**
     * @dev Core Function 1: Create a new digital identity
     * @param _name User's full name
     * @param _email User's email address
     */
    function createIdentity(string memory _name, string memory _email) external {
        require(!isRegistered[msg.sender], "Identity already exists");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_email).length > 0, "Email cannot be empty");
        
        Identity storage newIdentity = identities[msg.sender];
        newIdentity.name = _name;
        newIdentity.email = _email;
        newIdentity.isVerified = false;
        newIdentity.createdAt = block.timestamp;
        newIdentity.verifier = address(0);
        
        isRegistered[msg.sender] = true;
        
        emit IdentityCreated(msg.sender, _name, block.timestamp);
    }
    
    /**
     * @dev Core Function 2: Verify a user's identity
     * @param _userAddress Address of the user to verify
     */
    function verifyIdentity(address _userAddress) external onlyVerifier {
        require(isRegistered[_userAddress], "User is not registered");
        require(!identities[_userAddress].isVerified, "Identity already verified");
        
        identities[_userAddress].isVerified = true;
        identities[_userAddress].verifier = msg.sender;
        
        emit IdentityVerified(_userAddress, msg.sender, block.timestamp);
    }
    
    /**
     * @dev Core Function 3: Add credentials to user's identity
     * @param _credential Credential to add (e.g., "University Degree", "Professional Certificate")
     */
    function addCredential(string memory _credential) external onlyRegistered {
        require(bytes(_credential).length > 0, "Credential cannot be empty");
        require(identities[msg.sender].isVerified, "Identity must be verified to add credentials");
        
        identities[msg.sender].credentials.push(_credential);
        
        emit CredentialAdded(msg.sender, _credential, block.timestamp);
    }
    
    /**
     * @dev Get user's identity information
     * @param _userAddress Address of the user
     * @return name User's name
     * @return email User's email
     * @return isVerified Verification status
     * @return createdAt Creation timestamp
     * @return verifier Address of verifier
     */
    function getIdentity(address _userAddress) external view returns (
        string memory name,
        string memory email,
        bool isVerified,
        uint256 createdAt,
        address verifier
    ) {
        require(isRegistered[_userAddress], "User is not registered");
        require(
            msg.sender == _userAddress || 
            authorizedVerifiers[msg.sender] || 
            msg.sender == owner,
            "Unauthorized access to identity information"
        );
        
        Identity storage userIdentity = identities[_userAddress];
        return (
            userIdentity.name,
            userIdentity.email,
            userIdentity.isVerified,
            userIdentity.createdAt,
            userIdentity.verifier
        );
    }
    
    /**
     * @dev Get user's credentials
     * @param _userAddress Address of the user
     * @return Array of credentials
     */
    function getCredentials(address _userAddress) external view returns (string[] memory) {
        require(isRegistered[_userAddress], "User is not registered");
        require(
            msg.sender == _userAddress || 
            authorizedVerifiers[msg.sender] || 
            msg.sender == owner,
            "Unauthorized access to credentials"
        );
        
        return identities[_userAddress].credentials;
    }
    
    /**
     * @dev Authorize a new verifier
     * @param _verifier Address to authorize as verifier
     */
    function authorizeVerifier(address _verifier) external onlyOwner {
        require(_verifier != address(0), "Invalid verifier address");
        require(!authorizedVerifiers[_verifier], "Verifier already authorized");
        
        authorizedVerifiers[_verifier] = true;
        
        emit VerifierAuthorized(_verifier, block.timestamp);
    }
    
    /**
     * @dev Revoke verifier authorization
     * @param _verifier Address to revoke authorization from
     */
    function revokeVerifier(address _verifier) external onlyOwner {
        require(authorizedVerifiers[_verifier], "Verifier not authorized");
        require(_verifier != owner, "Cannot revoke owner's verifier status");
        
        authorizedVerifiers[_verifier] = false;
    }
    
    /**
     * @dev Check if an address is a registered user
     * @param _userAddress Address to check
     * @return Registration status
     */
    function isUserRegistered(address _userAddress) external view returns (bool) {
        return isRegistered[_userAddress];
    }
    
    /**
     * @dev Get total number of credentials for a user
     * @param _userAddress Address of the user
     * @return Number of credentials
     */
    function getCredentialCount(address _userAddress) external view returns (uint256) {
        require(isRegistered[_userAddress], "User is not registered");
        return identities[_userAddress].credentials.length;
    }
}
