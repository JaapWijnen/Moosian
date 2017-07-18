// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "Moosian",
    dependencies: [
        .package(url: "https://github.com/trill-lang/LLVMSwift.git", .exact("0.1.11"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Moosian",
            dependencies: ["LLVM"]),
    ]
)
