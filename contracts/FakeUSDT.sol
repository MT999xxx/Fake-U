// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title FakeUSDT - 仿 USDT 代币 (仅用于学习/测试)
 * @notice 这是一个标准 ERC-20 代币，名称和符号与 USDT 相同
 * @dev 
 *   - Name: "Tether USD" (与真实 USDT 完全一致)
 *   - Symbol: "USDT" (与真实 USDT 完全一致)
 *   - Decimals: 18 (BSC 上的 USDT 也是 18 位)
 *   - 初始供应量: 由部署者指定，全部 mint 给部署者
 *
 *   ⚠️ 免责声明：本合约仅供学习研究使用，请勿用于欺诈或非法活动。
 */
contract FakeUSDT {

    // ═══════════════════════════════════════════════════════════════
    //                        状态变量
    // ═══════════════════════════════════════════════════════════════

    string public name = "Tether USD";
    string public symbol = "USDT";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    /// @dev 持有者余额映射
    mapping(address => uint256) public balanceOf;
    
    /// @dev 授权映射: owner => spender => amount
    mapping(address => mapping(address => uint256)) public allowance;

    /// @dev 合约部署者（拥有者）
    address public owner;

    // ═══════════════════════════════════════════════════════════════
    //                          事件
    // ═══════════════════════════════════════════════════════════════

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ═══════════════════════════════════════════════════════════════
    //                        修饰器
    // ═══════════════════════════════════════════════════════════════

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    // ═══════════════════════════════════════════════════════════════
    //                       构造函数
    // ═══════════════════════════════════════════════════════════════

    /**
     * @notice 部署合约并铸造初始代币
     * @param _initialSupply 初始供应量（以整数计，例如 1000000 表示 100 万）
     *                       内部会自动乘以 10^decimals
     */
    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        uint256 supply = _initialSupply * 10 ** decimals;
        totalSupply = supply;
        balanceOf[msg.sender] = supply;
        emit Transfer(address(0), msg.sender, supply);
    }

    // ═══════════════════════════════════════════════════════════════
    //                     ERC-20 标准函数
    // ═══════════════════════════════════════════════════════════════

    /**
     * @notice 转账代币
     * @param _to 接收地址
     * @param _value 转账金额
     * @return success 是否成功
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Transfer to zero address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @notice 授权第三方使用自己的代币
     * @param _spender 被授权的地址
     * @param _value 授权额度
     * @return success 是否成功
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @notice 从被授权的地址转账代币
     * @param _from 代币来源地址
     * @param _to 代币目标地址
     * @param _value 转账金额
     * @return success 是否成功
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Transfer to zero address");
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }

    // ═══════════════════════════════════════════════════════════════
    //                      Owner 管理函数
    // ═══════════════════════════════════════════════════════════════

    /**
     * @notice Owner 可以额外铸造代币
     * @param _to 接收地址
     * @param _amount 铸造数量（以最小单位计）
     */
    function mint(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), "Mint to zero address");
        totalSupply += _amount;
        balanceOf[_to] += _amount;
        emit Transfer(address(0), _to, _amount);
    }

    /**
     * @notice 销毁自己的代币
     * @param _amount 销毁数量
     */
    function burn(uint256 _amount) external {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
    }

    /**
     * @notice 转移合约所有权
     * @param _newOwner 新的所有者地址
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    /**
     * @notice 放弃合约所有权（不可逆）
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}
