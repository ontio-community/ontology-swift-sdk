<h1 align="center">Swift SDK For Ontology blockchain </h1>

## Overview

Swift library for the Ontology blockchain. 

It supports:

* Wallet management
* Digital identity management
* Digital asset management
* Smart Contract deployment and invocation
* Ontology blockchain API

## Installation

### Carthage

```
github "ontio-community/ontology-swift-sdk" "master"
```

```swift
import OntSwift
```

> One of the reasons about fail to build this SDK is your network is unaccessible for some resources.
> SDK depends on some C libs and will download their source code and build them automatically, make sure your 
> network is accessible for those resources in `scripts/frameworks/*.sh`.
>
> You can use below command to list them all:
> 
> `grep -E "(git\sclone|curl\s-L)\shttps?" ./scripts/frameworks/*.sh`
>   

## For Developer

Install dependencies:

```bash
carthage update --platform iOS
```

Run tests via cli:

```bash
./run-tests.sh
```