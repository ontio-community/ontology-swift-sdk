#!/bin/sh 

set -o pipefail && \
  swiftformat . && \
  xcodebuild \
    -project OntSwift.xcodeproj \
    -scheme OntSwiftTestsHost \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 6,OS=12.1' \
    test | xcpretty --test --color 