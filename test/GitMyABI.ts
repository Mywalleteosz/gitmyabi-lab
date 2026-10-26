import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { network } from "hardhat";
import { SimpleStorage } from "gitmyabi-lab";

describe("GitMyABI client", async function () {
  const { viem } = await network.create();
  const publicClient = await viem.getPublicClient();
  const [walletClient] = await viem.getWalletClients();

  it("reads and writes through the generated package", async function () {
    const deployed = await viem.deployContract("SimpleStorage");

    const storage = new SimpleStorage(deployed.address, {
      publicClient,
      walletClient,
    });

    assert.equal(await storage.get(), 0n);

    const hash = await storage.set(42n);
    const receipt = await publicClient.waitForTransactionReceipt({ hash });

    assert.equal(receipt.status, "success");
    assert.equal(await storage.get(), 42n);
  });
});
