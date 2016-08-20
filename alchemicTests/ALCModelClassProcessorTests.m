//
//  ALCModelClassProcessorTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import OCMock;

#pragma mark - Dummy classes

@interface AMCPDummy1 : NSObject
@end

@implementation AMCPDummy1
static ALCClassObjectFactory *_of;
+(ALCClassObjectFactory *) of {
    return _of;
}
+(void) alchemic:(ALCClassObjectFactory *) objectFactory {
    _of = objectFactory;
}
@end

@interface AMCPDummy2 : NSObject
@end

@implementation AMCPDummy2
static ALCClassObjectFactory *_of;
+(ALCClassObjectFactory *) of {
    return _of;
}
+(void) _alc_register:(ALCClassObjectFactory *) objectFactory {
    _of = objectFactory;
}
@end

#pragma mark - Tests

@interface ALCModelClassProcessorTests : XCTestCase
@end

@implementation ALCModelClassProcessorTests {
    ALCModelClassProcessor *_processor;
}

-(void)setUp {
    _processor = [[ALCModelClassProcessor alloc] init];
}

-(void) testCanProcessorConfigClass {
    id mockClass = OCMClassMock([NSString class]);
    XCTAssertTrue([_processor canProcessClass:mockClass]);
}

-(void) testProcessorClassWithContextHasAlchemicMethod {
    
    id mockFactory = OCMClassMock([ALCClassObjectFactory class]);
    id mockContext = OCMProtocolMock(@protocol(ALCContext));
    
    OCMStub([mockContext registerObjectFactoryForClass:[AMCPDummy1 class]]).andReturn(mockFactory);
    
    [_processor processClass:[AMCPDummy1 class] withContext:mockContext];
    
    XCTAssertEqual(mockFactory, [AMCPDummy1 of]);
}

-(void) testProcessorClassWithContextHasAlchemicRegistrationMethod {
    
    id mockFactory = OCMClassMock([ALCClassObjectFactory class]);
    id mockContext = OCMProtocolMock(@protocol(ALCContext));
    
    OCMStub([mockContext registerObjectFactoryForClass:[AMCPDummy2 class]]).andReturn(mockFactory);
    
    [_processor processClass:[AMCPDummy2 class] withContext:mockContext];
    
    XCTAssertEqual(mockFactory, [AMCPDummy2 of]);
}

@end
