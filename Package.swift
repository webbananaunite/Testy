// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

/*
 Package.swift ONLY for Build target Linux.
 
 When targeting iOS, Open Testy.xcodeproj instead.
 */
import PackageDescription

#if os(Linux)
/*
 as Build on Linux.

 $ cd {Project Directory}
 $ TOOLCHAINS=org.swift.600202407161a swift build -v --swift-sdk x86_64-swift-linux-musl --build-path {App Output Path}/overlayNetwork
 */
#else
#endif
var productsSettings: [PackageDescription.Product] = []
var dependenciesSettings: [Package.Dependency] = []
var cSettings: [CSetting] = []
var swiftSettings: [SwiftSetting] = []
var linkerSettings: [LinkerSetting] = []

/*
 Should be Switch Linux or iOS
 */
productsSettings = [
    .executable(name: "TestyOnLinux", targets: ["TestyOnLinux"])
]
dependenciesSettings = [
    .package(url: "https://github.com/webbananaunite/blocks", .upToNextMajor(from: "0.4.0")),
//    .package(name: "blocks", path: "../blocks"),  //using local source code.
//    .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "3.4.0"))   //using as import Crypto
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
    ],
    products: productsSettings,
    dependencies: dependenciesSettings,
    targets: [
        //linux
        .executableTarget(
            name: "TestyOnLinux",
            dependencies: [
                .product(name: "blocks", package: "blocks"),
                // .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux])),
            ],
            path: "Sources/Testy",
            exclude: ["iOS"],
            resources: [.process("DomainService/Hash.metal"), .process("DomainService/Shader.metal")],
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
)
