- [部署合约](#%E9%83%A8%E7%BD%B2%E5%90%88%E7%BA%A6)
- [调用合约](#%E8%B0%83%E7%94%A8%E5%90%88%E7%BA%A6)
  - [通过 abi 文件构建交易](#%E9%80%9A%E8%BF%87-abi-%E6%96%87%E4%BB%B6%E6%9E%84%E5%BB%BA%E4%BA%A4%E6%98%93)

## 部署合约

部署合约需要构建并发送相应的交易到链上执行。

构建合约需要提供合约内容的十六进制字符串，和一些配置参数。

配置参数如下：

| 参数          | 含义                                     |
| ------------- | ---------------------------------------- |
| \$code        | 合约内容，十六进制的字符串。             |
| \$name        | 合约的名称。普通字符串。可选值。         |
| \$codeVersion | 合约的版本。普通字符串。可选值。         |
| \$author      | 合约作者。普通字符串。可选值。           |
| \$email       | 合约作者的邮件地址。普通字符串。可选值。 |
| \$desc        | 合约的描述。普通字符串。可选值。         |
| \$needStorage | 是否需要使用存储。布尔值。可选值。       |

```swift
// 合约编译后的字节码
let code = NSData(contentsOfFile: path)!

// 构造、签名交易
let b = TransactionBuilder()
let tx = try b.makeDeployCodeTransaction(
  code: code as Data,
  name: "name",
  codeVersion: "1.0", 
  author: "alice",
  email: "email",
  desc: "desc",
  needStorage: true,
  gasPrice: gasPrice,
  gasLimit: "30000000",
  payer: address1!
)
try b.sign(tx: tx, prikey: prikey1!)

try! rpc!.send(rawTransaction: tx.serialize(), preExec: false, waitNotify: true).then {
  // 打印结果
  print($0)
}
```

## 调用合约

合约必须在成功部署后才能调用。 调用合约需要构建并发送相应的交易到链上执行。

### 通过 abi 文件构建交易

针对于 NEO 虚拟机的智能合约可以编译出相应的 `.avm` 文件和 `.abi` 文件。`.abi` 文件是以 JSON 格式存储，包含了描述智能合约的方法和参数的内容。可以通过读取`.abi` 文件方便的构建调用合约的交易。构建的交易可能还需要使用用户的私钥签名。

为了对合约方法进行调用，我们需要得到该方法的 abi 信息，以此构造调用请求。abi 信息所涉及的类包括: `AbiInfo`，`AbiFunction` 和 `Parameter`。

`AbiInfo` 类用于将 `.abi` 文件的内容体现到内存中，方便对其中的方法信息的操作。

```swift
// 载入 abi
let path = bundle.path(forResource: "NeoVmTests.abi", ofType: "json")!
let json = NSData(contentsOfFile: path)! as Data
let abiFile = try JSONDecoder().decode(AbiFile.self, from: json)
let abi = abiFile.abi

// 需要调用的合约方法
let fn = abi!.function(name: "hello")!

// 构造用于合约调用的交易
let b = TransactionBuilder()
let tx = try b.makeInvokeTransaction(
  fnName: fn.name,
  // 合约方法所需的参数，因为数值已经包含了类型信息
  // 所以只需要指定数值关联的形参名称即可
  params: [
    false.abiParameter(name: "msgBool"),
    300.abiParameter(name: "msgInt"),
    Data(bytes: [1, 2, 3]).abiParameter(name: "msgByteArray"),
    "string".abiParameter(name: "msgStr"),
    contract.abiParameter(name: "msgAddress"),
  ],
  contract: contract,
  gasPrice: "0",
  gasLimit: "30000000",
  payer: address1
)
try b.sign(tx: tx, prikey: prikey1!)

try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
  XCTAssertEqual("SUCCESS", $0["Desc"].string!)

  // 反序列化合约方法的调用返回值 
  let bool = Bool(hex: $0["Result", "Result", 0].string!)
  let int = Int(hex: $0["Result", "Result", 1].string!)
  let data = Data.from(hex: $0["Result", "Result", 2].string!)!
  let str = String(hex: $0["Result", "Result", 3].string!)!
  let addr = Data.from(hex: $0["Result", "Result", 4].string!)!
}
```