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

Update your `Cartfile` to include below lines:

```
github "SwiftyJSON/SwiftyJSON" ~> 4.0
github "google/promises"
github "tidwall/SwiftWebSocket"

github "ontio-community/ontology-swift-sdk"
```

```swift
import OntSwift
```

## For Developer

Install dependencies:

```bash
carthage update --platform iOS
```

Run tests via cli:

```bash
./run-tests.sh
```