- [钱包数据规范](#%E9%92%B1%E5%8C%85%E6%95%B0%E6%8D%AE%E8%A7%84%E8%8C%83)
  - [创建钱包](#%E5%88%9B%E5%BB%BA%E9%92%B1%E5%8C%85)
  - [保存钱包](#%E4%BF%9D%E5%AD%98%E9%92%B1%E5%8C%85)
  - [导入钱包](#%E5%AF%BC%E5%85%A5%E9%92%B1%E5%8C%85)
- [公私钥和地址](#%E5%85%AC%E7%A7%81%E9%92%A5%E5%92%8C%E5%9C%B0%E5%9D%80)
  - [创建私钥](#%E5%88%9B%E5%BB%BA%E7%A7%81%E9%92%A5)
  - [导入私钥](#%E5%AF%BC%E5%85%A5%E7%A7%81%E9%92%A5)
  - [获取公钥](#%E8%8E%B7%E5%8F%96%E5%85%AC%E9%92%A5)
  - [获取地址](#%E8%8E%B7%E5%8F%96%E5%9C%B0%E5%9D%80)
- [账户](#%E8%B4%A6%E6%88%B7)
  - [创建账户](#%E5%88%9B%E5%BB%BA%E8%B4%A6%E6%88%B7)
  - [导入账户](#%E5%AF%BC%E5%85%A5%E8%B4%A6%E6%88%B7)
  - [加入钱包](#%E5%8A%A0%E5%85%A5%E9%92%B1%E5%8C%85)
  - [移除账户](#%E7%A7%BB%E9%99%A4%E8%B4%A6%E6%88%B7)
- [资产](#%E8%B5%84%E4%BA%A7)
  - [转账](#%E8%BD%AC%E8%B4%A6)
  - [余额查询](#%E4%BD%99%E9%A2%9D%E6%9F%A5%E8%AF%A2)

## 钱包数据规范

钱包用户存储多个数字身份以及数字资产账户。钱包文件采用 JSON 格式对数据进行组织，各个字段的详细可以参考[钱包文件规范](https://ontio.github.io/documentation/Wallet_File_Specification_cn.html)。

### 创建钱包

```swift
let wallet = Wallet(name: "mickey")
```

### 保存钱包

```swift
let walletJson = try! JSONEncoder().encode(w).utf8string
```

### 导入钱包

```swift
let str = "wallet_json"
let w = try JSONDecoder().decode(Wallet.self, from: str.data(using: .utf8)!)
```

## 公私钥和地址

账户是基于公私钥创建的，地址是公钥转换而来。

### 创建私钥 

使用默认的参数创建:

```swift
let prikey = try! PrivateKey.random()
```

用到的默认参数在 Constant 类中:

```swift
public final class Constant {

  public static let defaultAlgorithm = JSON([
    "algorithm": "ECDSA",
    "parameters": [
      "curve": "P-256",
    ],
  ])

  public static let defaultScrypt = JSON([
    "cost": 4096,
    "blockSize": 8,
    "parallel": 8,
    "size": 64,
  ])
}
```

使用指定的参数创建私钥:

```swift
let prikey = try! PrivateKey(
  raw: try! Data.random(count: 32),
  algorithm: .sm2,
  parameters: KeyParameters(curve: .sm2p256v1)
)
```

### 导入私钥 

直接导入:

```swift
let prikey = try PrivateKey(
  hex: "ab80a7ad086249c01e65c4d9bb6ce18de259dcfc218cd49f2455c539e9112ca3",
  algorithm: .sm2,
  parameters: KeyParameters(curve: .sm2p256v1)
)
```

从 WIF 导入:

```swift
let pri = try PrivateKey.from(wif: "L4shZ7B4NFQw2eqKncuUViJdFRq6uk1QUb6HjiuedxN4Q2CaRQKW")
```

### 获取公钥

```swift
let pubkey = try prikey.getPublicKey()
```

### 获取地址

当获取了公钥实例后，可以通过下面方式获得对应的地址:

```swift
let pubkey = try prikey.getPublicKey()
let addr = try Address.from(pubkey: pubkey)
```

## 账户

### 创建账户

```swift
let acc = try! Account.create(pwd: "123456")
```

### 导入账户

从 keystore 导入:

```swift
let str = "keystore_content"
let acc = try Account.from(keystore: str, pwd: "111111")
```

从 WIF 导入:

```swift
let acc = try Account.from(wif: "L4shZ7B4NFQw2eqKncuUViJdFRq6uk1QUb6HjiuedxN4Q2CaRQKW", pwd: "111111")
```

从助记词导入:

```swift
let mnemonic = "doll remember harbor resource desert curious fatigue nature arrest fix nation rhythm"
let acc = try Account.from(mnemonic: mnemonic, pwd: "111111")
```

### 加入钱包

```swift
let wallet = Wallet(name: "mickey")
let acc = try! Account.create(pwd: "123456")
wallet.add(account: acc)
```

### 移除账户

```swift
let wallet = Wallet(name: "mickey")
let acc = wallet.accounts[0]
wallet.delete(account: acc)
```

## 资产

本体中有两种原生资产: ONT 和 ONG

### 转账

下面是一个比较完整的对 ONT 进行转账的例子:

```swift
// 转账发起地址
let from = address1!
// 收款地址
let to = try Address(value: "AL9PtS6F8nue5MwxhzXCKaTpRb3yhtsix5")

let ob = OntAssetTxBuilder()
let tx = try ob.makeTransferTx(
  tokenType: "ONT",
  from: from,
  to: to,
  amount: BigInt(300), // 转账金额
  gasPrice: gasPrice,
  gasLimit: gasLimit,
  payer: from // 交易费用提供方地址，这里同转账发起地址
)

let txb = TransactionBuilder()
// 使用 payer 的私钥签名交易
try txb.sign(tx: tx, prikey: prikey1!)

// 通过 rpc 将交易发送到链上
let rpc = WebsocketRpc(url: "ws://127.0.0.1:20335")
rpc!.open()
try! rpc!.send(rawTransaction: tx.serialize()).then {
  // 打印结果
  print($0)
}
```

转账 ONG 与上面的流程基本一样，只是 `tokenType` 值替换为 `ONG` 即可。

### 余额查询

使用 RPC 来进行余额查询:

```swift
try! rpc!.getBalance(address: Address(value:"AL9PtS6F8nue5MwxhzXCKaTpRb3yhtsix5")).then {
  // 打印结果
  print($0)
}
```