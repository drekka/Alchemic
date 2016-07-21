//
//  ALCModelImplTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 21/7/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

@interface ALCModelImplTests : XCTestCase
@end

@implementation ALCModelImplTests {
    id<ALCModel> _model;
    id<ALCObjectFactory> _classFactory;
    id<ALCObjectFactory> _methodFactory;
}

-(void)setUp {
    _model = [[ALCModelImpl alloc] init];
    _classFactory = [_model classObjectFactoryForClass:[NSString class]];
    _methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:[NSString class]
                                               parentObjectFactory:_classFactory
                                                          selector:@selector(description)
                                                              args:nil];
    [_model addObjectFactory:_methodFactory withName:@"def"];
}

-(void) testObjectFactories {
    NSArray<id<ALCObjectFactory>> *factories = _model.objectFactories;
    XCTAssertEqual(2u, factories.count);
    XCTAssertTrue([factories containsObject:_classFactory]);
    XCTAssertTrue([factories containsObject:_methodFactory]);
}

@end
