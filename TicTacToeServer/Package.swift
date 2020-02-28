// swift-tools-version:4.2

import PackageDescription

let package = Package(
	name: "TicTacToeServer",
	products: [
		.executable(name: "TicTacToeServer", targets: ["TicTacToeServer"])
	],
	dependencies: [
//        .package(url: "https://github.com/PerfectlySoft/Perfect-WebSockets.git", from: "3.1.1"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
	],
	targets: [
		.target(name: "TicTacToeServer", dependencies: ["PerfectHTTPServer"])
	]
)
