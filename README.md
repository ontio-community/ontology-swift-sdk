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

> Make sure you've read the [Carthage Quick Start](https://github.com/Carthage/Carthage#quick-start)

1. Append below line at the end of your `Cartfile`

```
github "ontio-community/ontology-swift-sdk" "master"
```

2. Build SDK and it's dependencies:

```
carthage update --platform iOS
```

3. Drag SDK and it's dependencies into your project:

```
PROJ_DIR/Carthage/Build/iOS/OntSwift.framework
PROJ_DIR/Carthage/Build/iOS/SwiftyJSON.framework
PROJ_DIR/Carthage/Build/iOS/Promises.framework
PROJ_DIR/Carthage/Build/iOS/FBLPromises.framework
PROJ_DIR/Carthage/Build/iOS/SwiftWebSocket.framework
```

4. Input Files:

```
$(SRCROOT)/Carthage/Build/iOS/OntSwift.framework
$(SRCROOT)/Carthage/Build/iOS/SwiftyJSON.framework
$(SRCROOT)/Carthage/Build/iOS/Promises.framework
$(SRCROOT)/Carthage/Build/iOS/FBLPromises.framework
$(SRCROOT)/Carthage/Build/iOS/SwiftWebSocket.framework
```

5. Output Files:

```
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/OntSwift.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SwiftyJSON.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/Promises.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/FBLPromises.framework
$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SwiftWebSocket.framework
```

> One of the reasons about fail to build this SDK is your network is unaccessible for some resources.
> SDK depends on some C libs and will download their source code and build them automatically, make sure your 
> network is accessible for those resources in `scripts/frameworks/*.sh`.
>
> You can use below command to list them all:
> 
> `grep -E "(git\sclone|curl\s-L)\shttps?" ./scripts/frameworks/*.sh`
>   

## Usage

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