
- [创建身份](#%E5%88%9B%E5%BB%BA%E8%BA%AB%E4%BB%BD)
- [注册身份](#%E6%B3%A8%E5%86%8C%E8%BA%AB%E4%BB%BD)
- [查询 DDO](#%E6%9F%A5%E8%AF%A2-ddo)

## 创建身份

ONT ID 是一个去中心化的身份标识，能够管理用户的各种数字身份认证。数字身份(Identity)是 ONT SDK 导出的一个核心类，该类包含代表身份的 ONT ID 属性。可以通过 SDK 来创建一个身份。创建身份的过程中会基于用户的私钥生成 ONT ID。

> 有关 ONT ID 的规范，见 [ONT ID 生成规范](https://ontio.github.io/documentation/ONTID_protocol_spec_en.html)

```swift
let prikey = try! PrivateKey.random()
let id = try! Identity.create(prikey: prikey!, pwd: "123456", label: "mickey")
```

## 注册身份

身份创建完成后，还需要将身份的 ONT ID 注册到链上，身份才算真正地创建完成。发送 ONT ID 上链是需要发送交易的过程。可以通过调用 SDK 提供的方法构造交易对象。一种比较典型的场景是通过传递刚刚创建的 ONT ID 和用户的私钥来构造交易对象。

```swift
// 构造 ontid
let prikey = try! PrivateKey.random()
let account = try! Account.create(pwd: "123456", prikey: prikey, label: "", params: nil)
let address = account!.address
let ontid = try! "did:ont:" + address!.toBase58()

// 构造交易
let b = OntidContractTxBuilder()
let tx = try b.buildRegisterOntidTx(
  ontid: ontid,
  pubkey: prikey1!.getPublicKey(), // ontid 相关公钥
  gasPrice: gasPrice,
  gasLimit: gasLimit,
  payer: address1 // 交易费用提供地址
)

// 构造交易，并使用交易费用提供地址对应的私钥交易签名
let txb = TransactionBuilder()
try txb.sign(tx: tx, prikey: prikey1!)

// 发送交易
try! rpc!.send(rawTransaction: tx.serialize()).then {
  // 打印结果
  print($0)
}
```

## 查询 DDO

```swift
// 构造交易
let b = OntidContractTxBuilder()
let tx = try b.buildGetDDOTx(ontid: ontid!)

// 签名交易
let txb = TransactionBuilder()
try txb.sign(tx: tx, prikey: prikey1!)

try! rpc!.send(rawTransaction: tx.serialize(), preExec: true).then {
  // 打印结果
  print($0)
}
```