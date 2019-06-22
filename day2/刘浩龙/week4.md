# day2——第一次周报

## 本周工作

### Solidity学习
用僵尸游戏熟悉solidity的规则

#### 1. 版本指令
所有的 Solidity 源码都必须冠以 "version pragma" — 标明 Solidity 编译器的版本. 以避免将来新的编译器可能破坏你的代码。

例如: pragma solidity ^0.4.19; (当前 Solidity 的最新版本是 0.4.19).

#### 2. 状态变量和整数
状态变量是被永久地保存在合约中。也就是说它们被写入以太币区块链中. 想象成写入一个数据库。

```
contract Example {  // 这个无符号整数将会永久的被保存在区块链中
  uint myUnsignedInteger = 100;
}
```

#### 3. 结构体
有时你需要更复杂的数据类型，Solidity 提供了 结构体:

```
struct Person {
  uint age;  string name;
}

```

#### 4. 私有/公共函数
Solidity 定义的函数的属性默认为公共。 这就意味着任何一方 (或其它合约) 都可以调用你合约里的函数。

显然，不是什么时候都需要这样，而且这样的合约易于受到攻击。 所以将自己的函数定义为私有是一个好的编程习惯，只有当你需要外部世界调用它时才将它设置为公共。

定义一个私有函数：
```
uint[] numbers;function _addToArray(uint _number) private {
  numbers.push(_number);
}
```

#### 5. 函数修饰符view, returns
我们可以把函数定义为 view, 意味着它只能读取数据不能更改数据:
```
function sayHello() public view returns (string) {}
```

Solidity 还支持 pure 函数, 表明这个函数甚至都不访问应用里的数据，例如：
```
function _multiply(uint a, uint b) private pure returns (uint) {  return a * b;
}
```

#### 6. Keccak256和类型转换
散列函数 Keccak256

如何让 _generateRandomDna 函数返回一个全(半) 随机的 uint?

Ethereum 内部有一个散列函数keccak256，它用了SHA3版本。一个散列函数基本上就是把一个字符串转换为一个256位的16进制数字。字符串的一个微小变化会引起散列数据极大变化。

#### 7. 事件
事件 是合约和区块链通讯的一种机制。你的前端应用“监听”某些事件，并做出反应。