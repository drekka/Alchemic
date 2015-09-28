//
//  CircularDependency2IntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 2/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@class ObjA;
@class ObjB;

@interface ObjA : NSObject
@property (nonatomic, strong) ObjB *objB;
@end

@interface ObjB : NSObject
@property (nonatomic, strong) ObjA *objA;
@end

@implementation ObjA
AcInject(objB, AcClass(ObjB))
@end

@implementation ObjB
AcInject(objA, AcClass(ObjA))
@end

@interface CircularDependency2IntegrationTests : ALCTestCase
@end

@implementation CircularDependency2IntegrationTests {
	ObjA *_objA;
}

AcInject(_objA)

-(void) testCircularDep {
	[self setupRealContext];
	[self startContextWithClasses:@[[ObjB class], [ObjA class], [CircularDependency2IntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertNotNil(_objA);
    XCTAssertNotNil(_objA.objB);
    XCTAssertNotNil(_objA.objB.objA);
}

@end
