//
//  ModelInjectionTests.m
//  alchemic
//
//  Created by Derek Clarkson on 2/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "Component.h"
#import "InjectableObject.h"
#import "InjectableProtocol.h"
#import "Alchemic.h"

#import <objc/runtime.h>

@interface ModelInjectionTests : ALCTestCase<AlchemicAware>

@end

@implementation ModelInjectionTests {
    Component *_component;
    InjectableObject *_injectableObject;
    NSArray *_arrayOfComponents;
    BOOL callbackExecuted;
}

inject(intoVariable(_component))
inject(intoVariable(_injectableObject))
inject(intoVariable(_arrayOfComponents), withClass(Component), withProtocol(AlchemicAware))

-(void) setUp {
    injectDependencies(self);
}

-(void) testInjections {
    XCTAssertNotNil(_component);
    XCTAssertNotNil(_injectableObject);
    XCTAssertNotNil(_component.injObj);
    XCTAssertNotNil(_component.injProto);
    XCTAssertEqual(_injectableObject, _component.injObj);
    XCTAssertEqual(_injectableObject, _component.injProto);
    XCTAssertTrue(_component.awareCalled);
    XCTAssertTrue(callbackExecuted);
}

-(void) didResolveDependencies {
    callbackExecuted = YES;
}

@end
