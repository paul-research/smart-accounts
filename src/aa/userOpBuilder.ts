import { ethers } from "ethers";

export interface UserOperationStruct {
  sender: string;
  nonce: bigint;
  initCode: string;
  callData: string;
  callGasLimit: bigint;
  verificationGasLimit: bigint;
  preVerificationGas: bigint;
  maxFeePerGas: bigint;
  maxPriorityFeePerGas: bigint;
  paymasterAndData: string;
  signature: string;
}

export function buildUserOperation(params: Partial<UserOperationStruct>): UserOperationStruct {
  return {
    sender: params.sender ?? ethers.ZeroAddress,
    nonce: params.nonce ?? 0n,
    initCode: params.initCode ?? "0x",
    callData: params.callData ?? "0x",
    callGasLimit: params.callGasLimit ?? 0n,
    verificationGasLimit: params.verificationGasLimit ?? 0n,
    preVerificationGas: params.preVerificationGas ?? 0n,
    maxFeePerGas: params.maxFeePerGas ?? 0n,
    maxPriorityFeePerGas: params.maxPriorityFeePerGas ?? 0n,
    paymasterAndData: params.paymasterAndData ?? "0x",
    signature: params.signature ?? "0x",
  };
}

export function encodePaymasterData(paymaster: string, data: string = "0x") {
  return ethers.hexlify(ethers.concat([ethers.getBytes(paymaster), ethers.getBytes(data)]));
}

