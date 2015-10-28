
// Tests related to understanding the Swift language.

import Foundation
import XCTest


class SwiftLanguageTests: XCTestCase {

    class TestClass {
        var name:String?
        var xyz:String?
    }

    func testAccessingPropertiesOfAnyObjectInstancesReturnsNils() {
        let instance = TestClass()
        instance.xyz = "xyz"
        instance.name = "name"

        let typeAnyObject = instance as AnyObject

        // Won't compile because 'xyz' is an unknown property in any class.
        //XCTAssertEqual("xyz", typeAnyObject.xyz)

        // Will compile because 'name' is a property of NSException
        // But returns a nil when accessed.
        XCTAssertEqual("name", typeAnyObject.name)

    }


    func testUsingAGenericTypeDerivedFromTheReturnType() {

        func createTestClass() -> TestClass {
            let obj = TestClass()
            obj.xyz = "abc"
            return obj
        }

        func getObj<T>() -> T {
            //var obj2 = createTestClass()
            let obj = TestClass()
            obj.xyz = "abc"
            return obj as! T
        }

        let unknownTypeObj:TestClass = getObj()

        let theName = unknownTypeObj.xyz
        XCTAssertEqual("abc", theName)
    }

    func testUsingAGenericTypeDerivedFromAClassArgument() {

        func getObj<T>(arg:T.Type) -> T {
            let obj = TestClass()
            obj.xyz = "abc"
            return obj as! T
            //return createTestClass() as! T
        }

        let unknownTypeObj = getObj(TestClass.self)

        let theName = unknownTypeObj.xyz
        XCTAssertEqual("abc", theName)
    }

}
