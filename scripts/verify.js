/**
 * @file verify.js
 * @description 合约验证脚本 - 在 BSCScan 上开源验证合约代码
 * 
 * 用法：
 *   npx hardhat run scripts/verify.js --network bsc
 * 
 * 注意：需要先在 .env 中配置 BSCSCAN_API_KEY
 * 如果自动验证失败（ECONNRESET），请参考 manual_verify.md 进行手动验证
 */
const hre = require("hardhat");

// ⚠️ 部署后替换为实际的合约地址
const CONTRACT_ADDRESS = "替换为你的合约地址";
const INITIAL_SUPPLY = process.env.INITIAL_SUPPLY || "1000000000";

async function main() {
  console.log("═══════════════════════════════════════════════════");
  console.log("  BSCScan 合约验证");
  console.log("═══════════════════════════════════════════════════");
  console.log(`  合约地址: ${CONTRACT_ADDRESS}`);
  console.log(`  构造函数参数: ${INITIAL_SUPPLY}`);
  console.log("═══════════════════════════════════════════════════\n");

  try {
    await hre.run("verify:verify", {
      address: CONTRACT_ADDRESS,
      constructorArguments: [INITIAL_SUPPLY],
    });
    console.log("\n✅ 合约验证成功！");
  } catch (error) {
    if (error.message.includes("Already Verified")) {
      console.log("\n✅ 合约已经验证过了。");
    } else {
      console.error("\n❌ 验证失败:", error.message);
      console.log("\n💡 如果是网络超时(ECONNRESET)，请使用手动验证：");
      console.log("   参考: doc/manual_verify.md");
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
