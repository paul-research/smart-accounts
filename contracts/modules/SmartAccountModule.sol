// SPDX-License-Identifier: Apache-2.0
/*
 * Minimal smart-account module that bridges EntryPoint-based accounts
 * with application contracts expecting msg.sender == EOA.
 */

pragma solidity ^0.8.24;

import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

contract SmartAccountModule is EIP712 {
    error NotEntryPoint();
    error InvalidSignature();

    address public immutable entryPoint;

    bytes32 private constant MESSAGE_CALL_TYPEHASH = keccak256(
        "MessageCall(address account,address target,bytes data,uint256 nonce)"
    );

    bytes32 private constant PAYMENT_CALL_TYPEHASH =
        keccak256("PaymentCall(address account,address target,bytes data,uint256 value,uint256 nonce)");

    mapping(address => uint256) public nonces;

    constructor(address _entryPoint) EIP712("SmartAccountModule", "1") {
        entryPoint = _entryPoint;
    }

    modifier onlyEntryPoint() {
        if (msg.sender != entryPoint) revert NotEntryPoint();
        _;
    }

    struct MessageCall {
        address account;
        address target;
        bytes data;
        uint256 nonce;
        bytes signature;
    }

    struct PaymentCall {
        address account;
        address target;
        bytes data;
        uint256 value;
        uint256 nonce;
        bytes signature;
    }

    function executeMessageCall(MessageCall calldata call) external onlyEntryPoint {
        _verifyMessageCall(call);
        (bool success, bytes memory returndata) = call.target.call(call.data);
        if (!success) {
            assembly {
                revert(add(returndata, 32), mload(returndata))
            }
        }
    }

    function executePaymentCall(PaymentCall calldata call) external onlyEntryPoint {
        _verifyPaymentCall(call);
        (bool success, bytes memory returndata) = call.target.call{value: call.value}(call.data);
        if (!success) {
            assembly {
                revert(add(returndata, 32), mload(returndata))
            }
        }
    }

    function _verifyMessageCall(MessageCall calldata call) internal {
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_CALL_TYPEHASH, call.account, call.target, keccak256(call.data), call.nonce))
        );

        if (!SignatureChecker.isValidSignatureNow(call.account, digest, call.signature)) {
            revert InvalidSignature();
        }

        if (call.nonce != nonces[call.account]++) {
            revert InvalidSignature();
        }
    }

    function _verifyPaymentCall(PaymentCall calldata call) internal {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    PAYMENT_CALL_TYPEHASH,
                    call.account,
                    call.target,
                    keccak256(call.data),
                    call.value,
                    call.nonce
                )
            )
        );

        if (!SignatureChecker.isValidSignatureNow(call.account, digest, call.signature)) {
            revert InvalidSignature();
        }

        if (call.nonce != nonces[call.account]++) {
            revert InvalidSignature();
        }
    }
}

