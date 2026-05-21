// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
 Package.swift ONLY for Build target Linux.
 
 When targeting iOS, Open Testy.xcodeproj instead.
 */
import PackageDescription

#if os(Linux)
/*
 as Build on macOS. in 20250530

 //
 //download & install Swifty tool chain & Static linux sdk
 //
 $ curl -O https://download.swift.org/swiftly/darwin/swiftly.pkg && installer -pkg swiftly.pkg -target CurrentUserHomeDirectory && ~/.swiftly/bin/swiftly init --quiet-shell-followup && . ${SWIFTLY_HOME_DIR:-~/.swiftly}/env.sh && hash -r
 $ download Static Linux SDK https://www.swift.org/install/macos/
 $ xattr -d -r -s com.apple.quarantine "{Downloads dir}/swift-6.1.2-RELEASE_static-linux-0.0.1.artifactbundle.tar"
 $ swift sdk install {Downloads dir}/swift-6.1.2-RELEASE_static-linux-0.0.1.artifactbundle.tar --checksum df0b40b9b582598e7e3d70c82ab503fd6fbfdff71fd17e7f1ab37115a0665b3b
 //
 //cross compile for Linux
 //
 $ cd {Project Directory}
 $ TOOLCHAINS=org.swift.612202505261a swift build -v --swift-sdk x86_64-swift-linux-musl --build-path {App Output Path}/Testy
 */
#else
#endif
var productsSettings: [PackageDescription.Product] = []
var dependenciesSettings: [Package.Dependency] = []
var cSettings: [CSetting] = []
var swiftSettings: [SwiftSetting] = []
var linkerSettings: [LinkerSetting] = []
var targetsSettings: [PackageDescription.Target] = []

/*
 Should be Switch Linux or iOS
 */
productsSettings = [
    .executable(name: "TestyOnLinux", targets: ["TestyOnLinux"])
]
dependenciesSettings = [
    .package(url: "https://github.com/webbananaunite/blocks", .upToNextMajor(from: "0.5.4")), //using source code in github tag
//    .package(name: "blocks", path: "../blocks"),  //using source code in same device.
//    .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "3.4.0"))   //using as import Crypto
    .package(url: "https://github.com/webbananaunite/SharedDesignSystem", .upToNextMajor(from: "0.1.0")), //using source code in github tag
//    .package(name: "SharedDesignSystem", path: "../SharedDesignSystem"),  //using source code in same device.
]

/*
 os() Preprocessor represent build environment OS in Package.swift Manifest.
 */
#if os(Linux)
/*
 as Build on Linux.
 */
cSettings = [
    .unsafeFlags(["-I" + includePath]),
]
swiftSettings = [
    .unsafeFlags(["-I" + includePath]),
]
linkerSettings = [
    .linkedLibrary("c++"),
]
#else
/*
 as Build iOS library on macOS.
 Xcode Build
 
 or
 as Linux Cross-Compile on macOS.

 $ cd {Project Directory}
 $ TOOLCHAINS=org.swift.600202407161a swift build -v --swift-sdk x86_64-swift-linux-musl --build-path {App Output Path}/overlayNetwork
 */
linkerSettings = [
    .linkedLibrary("c++"),
]
#endif
targetsSettings = [
    //linux
    .executableTarget(
        name: "TestyOnLinux",
        dependencies: [
            .product(name: "blocks", package: "blocks"),
            // .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux])),
        ],
        path: "Sources/Testy",
        exclude: ["iOS"],
//            resources: [.process("DomainService/Hash.metal"), .process("DomainService/Shader.metal")],
        cSettings: cSettings,
        swiftSettings: swiftSettings,
        linkerSettings: linkerSettings
    ),
    .testTarget(
        name: "TestyOnLinuxTests",
        dependencies: [
            "TestyOnLinux"
        ],
        path: "TestyTests",
        linkerSettings: linkerSettings
    ),
]

/*
 Should be Switch Linux or iOS
 */
let package = Package(
    name: "Testy",
    defaultLocalization: "ja",
    /*
     as Swift version check on Xcode Build.
     */
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
        .macOS(.v13)
    ],
    products: productsSettings,
    dependencies: dependenciesSettings,
    targets: targetsSettings
)
