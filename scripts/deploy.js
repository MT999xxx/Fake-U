/**
 * @file deploy.js
 * @description FakeUSDT 部署脚本
 * 
 * 用法：
 *   测试网部署：npx hardhat run scripts/deploy.js --network bscTestnet
 *   主网部署：  npx hardhat run scripts/deploy.js --network bsc
 */
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  
  console.log("═══════════════════════════════════════════════════");
  console.log("  FakeUSDT 部署脚本");
  console.log("═══════════════════════════════════════════════════");
  console.log(`  部署者地址: ${deployer.address}`);
  
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log(`  部署者余额: ${hre.ethers.formatEther(balance)} BNB`);
  console.log("═══════════════════════════════════════════════════\n");

  // 初始供应量 (从环境变量读取，默认 10 亿)
  const initialSupply = process.env.INITIAL_SUPPLY || "1000000000";
  console.log(`📦 初始供应量: ${Number(initialSupply).toLocaleString()} USDT`);

  // 部署合约
  console.log("\n🚀 正在部署 FakeUSDT 合约...\n");
  const FakeUSDT = await hre.ethers.getContractFactory("FakeUSDT");
  const token = await FakeUSDT.deploy(initialSupply);
  await token.waitForDeployment();

  const contractAddress = await token.getAddress();

  console.log("═══════════════════════════════════════════════════");
  console.log("  ✅ 部署成功！");
  console.log("═══════════════════════════════════════════════════");
  console.log(`  合约地址:    ${contractAddress}`);
  console.log(`  代币名称:    ${await token.name()}`);
  console.log(`  代币符号:    ${await token.symbol()}`);
  console.log(`  精度:        ${await token.decimals()}`);
  console.log(`  总供应量:    ${hre.ethers.formatEther(await token.totalSupply())} USDT`);
  console.log(`  部署者余额:  ${hre.ethers.formatEther(await token.balanceOf(deployer.address))} USDT`);
  console.log("═══════════════════════════════════════════════════\n");

  // 输出 BSCScan 链接
  const network = hre.network.name;
  const explorerBase = network === "bsc" 
    ? "https://bscscan.com" 
    : "https://testnet.bscscan.com";
  
  console.log(`🔗 BSCScan: ${explorerBase}/address/${contractAddress}`);
  console.log(`🔗 Token:   ${explorerBase}/token/${contractAddress}`);

  // 提示验证命令
  console.log("\n📋 合约验证命令（部署后执行）:");
  console.log(`   npx hardhat verify --network ${network} ${contractAddress} ${initialSupply}`);
  console.log("");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ 部署失败:", error);
    process.exit(1);
  });
