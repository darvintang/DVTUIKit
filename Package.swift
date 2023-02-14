// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

fileprivate struct PackageInfo {
    init(package: String? = nil, name: String, version: Version, url: String? = nil) {
        self._package = package
        self.name = name
        self.version = version
        self._url = url
    }

    private var _package: String?

    var name: String
    var package: String {
        if let package = self._package {
            return package
        }
        return self.name
    }

    var version: PackageDescription.Version

    private var _url: String?
    var url: String {
        if let url = self._url {
            return url
        }
        return "https://github.com/darvintang/" + self.package + ".git"
    }
}

fileprivate enum RemotePackage: CaseIterable {
    case foundation
    case loger

    var info: PackageInfo {
        switch self {
            case .foundation:
                return PackageInfo(name: "DVTFoundation", version: "2.0.6")
            case .loger:
                return PackageInfo(name: "DVTLoger", version: "2.0.2")
        }
    }

    var packageDependency: Package.Dependency {
        .package(url: self.info.url, .upToNextMinor(from: self.info.version))
    }

    var targetDependency: Target.Dependency {
        .product(name: self.info.name, package: self.info.package)
    }

    static var packageDependencys: [Package.Dependency] {
        self.allCases.map { $0.packageDependency }
    }

    static var targetDependencys: [Target.Dependency] {
        self.allCases.map { $0.targetDependency }
    }
}

fileprivate struct ProductInfo {
    var prefix: String = ""
    var name: String
    var path: String = ""
    var exclude: [String] = []

    var dependencies: [ProductInfo] = []
    var remoteDependencies: [RemotePackage] = []

    var realName: String { self.prefix + (self.prefix.isEmpty ? "" : ".") + self.name }

    var product: Product {
        .library(name: self.realName, targets: [self.realName])
    }

    var target: Target {
        .target(name: self.realName, dependencies: self.dependencies.map({ $0.dependency }) + self.remoteDependencies.map({ $0.targetDependency }), path: self.path, exclude: self.exclude)
    }

    var dependency: Target.Dependency {
        .target(name: self.realName)
    }
}

fileprivate protocol ProductInfoProtocol: CaseIterable {
    var info: ProductInfo { get }
}

fileprivate extension ProductInfoProtocol {
    static var products: [Product] {
        self.allCases.map { $0.info.product }
    }

    static var allInfos: [ProductInfo] {
        self.allCases.map({ $0.info })
    }
}

fileprivate enum LocalPackage: String, ProductInfoProtocol {
    case oneself = "DVTUIKit"
    enum Advanced: String, ProductInfoProtocol {
        case button, collection,
             label,
             navigation, progress,
             `public`, tips
        var info: ProductInfo {
            let prefixPath = "Sources/Advanced/"
            var dependencies: [Self] = []

            switch self {
                case .progress, .tips:
                    dependencies.append(.public)
                default:
                    break
            }
            return ProductInfo(prefix: "DVTUIKit", name: self.uRawValue, path: prefixPath + self.uRawValue,
                               dependencies: dependencies.map({ $0.info }) + [LocalPackage.Extension.oneself.info])
        }

        var uRawValue: String {
            self.rawValue.capitalized
        }
    }

    enum Extension: String, ProductInfoProtocol {
        case oneself = "Extension"
        var info: ProductInfo {
            let prefixPath = "Sources/Extension"
            return ProductInfo(prefix: "DVTUIKit", name: self.rawValue,
                               path: prefixPath + (self == .oneself ? "" : ("/" + self.rawValue)),
                               dependencies: [], remoteDependencies: RemotePackage.allCases)
        }
    }

    var platforms: [SupportedPlatform] {
        [.iOS(.v13)]
    }

    var info: ProductInfo {
        return ProductInfo(name: self.rawValue, path: "Sources", exclude: ["Advanced", "Extension"],
                           dependencies: Self.Advanced.allInfos + Self.Extension.allInfos)
    }

    func getPackage() -> Package {
        Package(
            name: self.rawValue,
            platforms: self.platforms,
            products: (Self.allInfos + Self.Extension.allInfos + Self.Advanced.allInfos).map({ $0.product }),
            dependencies: RemotePackage.packageDependencys,
            targets: (Self.allInfos + Self.Extension.allInfos + Self.Advanced.allInfos).map({ $0.target })
        )
    }
}

let package = LocalPackage.oneself.getPackage()
