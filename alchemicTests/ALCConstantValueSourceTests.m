//
//  ALCConstantValueSourceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 3/9/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;

@interface ALCConstantValueSourceTests : XCTestCase

@end

@implementation ALCConstantValueSourceTests

#define testScalar(methodName, function, type, validate) \
-(void) testConstant ## methodName { \
id<ALCValueSource> source = function; \
ALCValue *alcValue = source.value; \
XCTAssertNotNil(alcValue); \
NSValue *nsValue = alcValue.object; \
type result; \
[nsValue getValue:&result]; \
validate; \
}

testScalar(Bool, AcBool(YES), BOOL, XCTAssertTrue(result))
testScalar(Char, AcChar('a'), char, XCTAssertEqual('a', result))
testScalar(CString, AcCString("abc"), char *, XCTAssertTrue(strcmp("abc", result) == 0))
testScalar(Double, AcDouble(5), double, XCTAssertEqual(5, result))
testScalar(Float, AcFloat(5.1234f), float, XCTAssertEqualWithAccuracy(5.1234f, result, 0.0001f))
testScalar(Int, AcInt(5), int, XCTAssertEqual(5, result))
testScalar(Long, AcLong(5), long, XCTAssertEqual(5, result))
testScalar(LongLong, AcLongLong(5), long long, XCTAssertEqual(5, result))
testScalar(Short, AcShort(5), short, XCTAssertEqual(5, result))
testScalar(UnsignedChar, AcUnsignedChar('a'), unsigned char, XCTAssertEqual('a', result))
testScalar(UnsignedInt, AcUnsignedInt(5), unsigned int, XCTAssertEqual(5u, result))
testScalar(UnsignedLong, AcUnsignedLong(5), unsigned long, XCTAssertEqual(5u, result))
testScalar(UnsignedLongLong, AcUnsignedLongLong(5), unsigned long long, XCTAssertEqual(5u, result))
testScalar(UnsignedShort, AcUnsignedShort(5), unsigned short, XCTAssertEqual(5, result))
testScalar(Size, AcSize(1.0f,2.0f), CGSize, XCTAssertTrue(CGSizeEqualToSize(result, CGSizeMake(1.0f,2.0f))))
testScalar(Point, AcPoint(1.0f,2.0f), CGPoint, XCTAssertTrue(CGPointEqualToPoint(result, CGPointMake(1.0f,2.0f))))
testScalar(Rect, AcRect(1.0f,2.0f,3.0f,4.0f), CGRect, XCTAssertTrue(CGRectEqualToRect(result, CGRectMake(1.0f,2.0f,3.0f,4.0f))))

-(void) testConstantString {
    id<ALCValueSource> source = AcString(@"abc");
    ALCValue *alcValue = source.value;
    XCTAssertNotNil(alcValue);
    XCTAssertEqualObjects(@"abc", alcValue.object);
}


@end
