import { task } from "hardhat/config";
import { buildUserOperation, encodePaymasterData } from "../src/aa/userOpBuilder";

task("aa:sample-userop", "Prints a sample user operation payload")
  .addParam("sender", "Smart account address")
  .addParam("callData", "Encoded call data")
  .addOptionalParam("paymaster", "Paymaster address", "0x0000000000000000000000000000000000000000")
  .setAction(async (args) => {
    const userOp = buildUserOperation({
      sender: args.sender,
      callData: args.callData,
      paymasterAndData: encodePaymasterData(args.paymaster),
    });
    console.log(JSON.stringify(userOp, null, 2));
  });

