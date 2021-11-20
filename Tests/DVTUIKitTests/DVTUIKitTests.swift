@testable import DVTUIKit
import XCTest

final class DVTUIKitTests: XCTestCase {
    func testExample() throws {
        let image = UIImage(dvt: [.blue, .red],size: CGSize(width: 300, height: 300))
        let newImage = image?.dvt.to(new: 400)
        print(newImage?.size)
        print(newImage?.scale)
    }
}
