//
//  FactoryTests.m
//  alchemic
//
//  Created by Derek Clarkson on 14/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Alchemic.h"
#import "Component.h"

@interface FactoryTests : XCTestCase

@end

@implementation FactoryTests {
    NSString *string1;
    NSString *string2;
    NSArray *arrayOfComponents;
    id idArrayOfComponents;
}

inject(intoVariable(string1), withName(@"buildADateString"))
inject(intoVariable(string2), withName(@"buildADateString"))
inject(intoVariable(arrayOfComponents), withClass(Component))
inject(intoVariable(idArrayOfComponents), withClass(Component))

- (void)setUp {
    injectDependencies(self);
}

- (void)testSimpleFactoryMethod {
    XCTAssertTrue([string1 hasPrefix:@"Factory string"]);
    XCTAssertTrue([string2 hasPrefix:@"Factory string"]);
    XCTAssertNotEqualObjects(string1, string2);
}

-(void) testArrayOfComponents {
    XCTAssertEqual(2lu, [arrayOfComponents count]);
    Component *comp1 = arrayOfComponents[0];
    Component *comp2 = arrayOfComponents[1];
    XCTAssertTrue([comp1 isKindOfClass:[Component class]]);
    XCTAssertTrue([comp2 isKindOfClass:[Component class]]);
    XCTAssertNotEqual(comp1, comp2);
}

-(void) testIdArrayOfComponents {
    XCTAssertEqual(2lu, [idArrayOfComponents count]);
    Component *comp1 = idArrayOfComponents[0];
    Component *comp2 = idArrayOfComponents[1];
    XCTAssertTrue([comp1 isKindOfClass:[Component class]]);
    XCTAssertTrue([comp2 isKindOfClass:[Component class]]);
    XCTAssertNotEqual(comp1, comp2);
}

@end
