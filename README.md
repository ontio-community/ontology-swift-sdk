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

SDK depends on some C libs and it will download and compile the source code of those C libs automatically by
adding a new build phase `Build Libraries` which runs the build script `scripts/frameworks/build_all.sh`. It will
take some time to finish the build process.

Please keep your network is accessible for downloading those C libs. Below is a command to list all the URLs of those C libs: 

```bash
grep -E "(git\sclone|curl\s-L)\shttps?" ./scripts/frameworks/*.sh
```


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

[文档](./doc/cn)