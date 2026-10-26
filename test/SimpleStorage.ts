import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";

describe("SimpleStorage", async function () {
  const { viem } = await network.create();
  const publicClient = await viem.getPublicClient();

  it("stores 42 after starting at zero", async function () {
    const storage = await viem.deployContract("SimpleStorage");

    assert.equal(await storage.read.get(), 0n);

    const hash = await storage.write.set([42n]);
    const receipt = await publicClient.waitForTransactionReceipt({ hash });

    assert.equal(receipt.status, "success");
    assert.equal(await storage.read.get(), 42n);
  });
});
