- [实例化 RPC 客户端](#%E5%AE%9E%E4%BE%8B%E5%8C%96-rpc-%E5%AE%A2%E6%88%B7%E7%AB%AF)
- [获取当前区块高度](#%E8%8E%B7%E5%8F%96%E5%BD%93%E5%89%8D%E5%8C%BA%E5%9D%97%E9%AB%98%E5%BA%A6)
- [获取区块](#%E8%8E%B7%E5%8F%96%E5%8C%BA%E5%9D%97)
- [获得 block json 数据](#%E8%8E%B7%E5%BE%97-block-json-%E6%95%B0%E6%8D%AE)
- [根据合约 hash 获得合约代码](#%E6%A0%B9%E6%8D%AE%E5%90%88%E7%BA%A6-hash-%E8%8E%B7%E5%BE%97%E5%90%88%E7%BA%A6%E4%BB%A3%E7%A0%81)
- [查询余额](#%E6%9F%A5%E8%AF%A2%E4%BD%99%E9%A2%9D)
- [获取区块链节点数](#%E8%8E%B7%E5%8F%96%E5%8C%BA%E5%9D%97%E9%93%BE%E8%8A%82%E7%82%B9%E6%95%B0)
- [获得智能合约事件](#%E8%8E%B7%E5%BE%97%E6%99%BA%E8%83%BD%E5%90%88%E7%BA%A6%E4%BA%8B%E4%BB%B6)
- [根据交易 hash 获得区块高度](#%E6%A0%B9%E6%8D%AE%E4%BA%A4%E6%98%93-hash-%E8%8E%B7%E5%BE%97%E5%8C%BA%E5%9D%97%E9%AB%98%E5%BA%A6)
- [获得 merkle proof](#%E8%8E%B7%E5%BE%97-merkle-proof)
- [根据交易 hash 获得交易 json 数据](#%E6%A0%B9%E6%8D%AE%E4%BA%A4%E6%98%93-hash-%E8%8E%B7%E5%BE%97%E4%BA%A4%E6%98%93-json-%E6%95%B0%E6%8D%AE)

## 实例化 RPC 客户端

在进行 RPC 调用前，需要先对客户端进行实例化:

```swift
let rpc = WebsocketRpc(url: "ws://127.0.0.1:20335")!
rpc.open()
```

## 获取当前区块高度

```swift
rpc.getBlockHeight().then {
  print($0)
}
```

## 获取区块

```swift
rpc.getBlock(by: hash).then {
  print($0)
}

rpc.getBlock(by: height).then {
  print($0)
}
```

## 获得 block json 数据

```swift
rpc.getBlock(by: hash, json: true).then {
  print($0)
}
```

## 根据合约 hash 获得合约代码

```swift
rpc.getContract(by: hash, json: true).then {
  print($0)
}
```

## 查询余额

```swift
rpc.getBalance(address: addr).then {
  print($0)
}
```

## 获取区块链节点数

```swift
rpc.getNodeCount().then {
  print($0)
}
```

## 获得智能合约事件

```swift
rpc.getSmartCodeEvent(by: hash).then {
  print($0)
}

rpc.getSmartCodeEvent(by: height).then {
  print($0)
}
```

## 根据交易 hash 获得区块高度

```swift
rpc.getBlockHeight(by: hash).then {
  print($0)
}
```

## 获得 merkle proof

```swift
rpc.getMerkleProof(hash: hash).then {
  print($0)
}
```

## 根据交易 hash 获得交易 json 数据

```swift
rpc.getRawTransaction(txHash: hash, json: true).then {
  print($0)
}
```
