// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

/**
 * Minimal ERC-4337 style paymaster skeleton to showcase shared funding logic.
 * Not production ready; add rate limiting, audit logging, and auth before deploying.
 */

interface IEntryPoint {
    function depositTo(address) external payable;
    function withdrawTo(address, uint256) external;
}

enum PostOpMode {
    opSucceeded,
    opReverted,
    postOpReverted
}

struct UserOperation {
    address sender;
    uint256 nonce;
    bytes initCode;
    bytes callData;
    uint256 callGasLimit;
    uint256 verificationGasLimit;
    uint256 preVerificationGas;
    uint256 maxFeePerGas;
    uint256 maxPriorityFeePerGas;
    bytes paymasterAndData;
    bytes signature;
}

interface IPaymaster {
    function validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 maxCost
    ) external returns (bytes memory context, uint256 validationData);

    function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external;
}

contract Paymaster is IPaymaster {
    IEntryPoint public immutable entryPoint;
    address public owner;
    mapping(address => bool) public allowedSenders;

    event Deposited(uint256 amount);
    event Withdrawn(address indexed recipient, uint256 amount);
    event SenderAllowed(address indexed sender, bool allowed);

    modifier onlyEntryPoint() {
        require(msg.sender == address(entryPoint), "Not entry point");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(IEntryPoint _entryPoint) {
        entryPoint = _entryPoint;
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero owner");
        owner = newOwner;
    }

    function setAllowedSender(address sender, bool allowed) external onlyOwner {
        allowedSenders[sender] = allowed;
        emit SenderAllowed(sender, allowed);
    }

    function deposit() external payable {
        entryPoint.depositTo{value: msg.value}(address(this));
        emit Deposited(msg.value);
    }

    function withdraw(address payable recipient, uint256 amount) external onlyOwner {
        entryPoint.withdrawTo(recipient, amount);
        emit Withdrawn(recipient, amount);
    }

    function validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32,
        uint256
    ) external view override onlyEntryPoint returns (bytes memory context, uint256 validationData) {
        if (!allowedSenders[userOp.sender]) {
            revert("Sender not allowed");
        }
        // return the sender address as context for postOp accounting
        context = abi.encode(userOp.sender);
        validationData = 0;
    }

    function postOp(PostOpMode, bytes calldata, uint256) external override onlyEntryPoint {
        // accounting / logging can take place here
    }

    receive() external payable {
        entryPoint.depositTo{value: msg.value}(address(this));
        emit Deposited(msg.value);
    }
}

