import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OWNER = "0xEed52c0Df5C3D33c19de7A9BFd06011924251Da5";

export default buildModule("OwnerVaultModule", (m) => {
  const ownerVault = m.contract("OwnerVault", [OWNER]);

  return { ownerVault };
});
