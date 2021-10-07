@testable import DVTUIKit
import XCTest

final class DVTUIKitTests: XCTestCase {
    func testExample() throws {
        let image = UIImage(dvt: [.blue, .red])
        print(image)
    }
}
