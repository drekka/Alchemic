//
//  ReferenceTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"
#import "ALCModelSearchCriteria.h"
#import "ALCModelDependency.h"

@interface TestRefClass1:NSObject
@end

@implementation TestRefClass1
@end

@interface TestRefClass2:NSObject
@property (nonatomic, strong) TestRefClass1 *ref1;
@end

@implementation TestRefClass2
@end

@interface ExternalReferences : XCTestCase
@end

@implementation ExternalReferences

-(void) testSingleReference {

    id<ALCContext> context = [[ALCContextImpl alloc] init];
    ALCClassObjectFactory *valueFactory = [context registerClass:[TestRefClass1 class]];
    valueFactory.factoryType = ALCFactoryTypeReference;
    
    [context start];

    XCTAssertFalse(valueFactory.ready);

    id object = [[TestRefClass1 alloc] init];
    valueFactory.object = object;

    XCTAssertTrue(valueFactory.ready);

    id storedObject = valueFactory.object;
    XCTAssertEqual(object, storedObject);

}

-(void) testCallbackBlockTriggersSingletonCreation {

    id<ALCContext> context = [[ALCContextImpl alloc] init];

    ALCClassObjectFactory *valueFactory1 = [context registerClass:[TestRefClass1 class]];
    ALCClassObjectFactory *valueFactory2 = [context registerClass:[TestRefClass2 class]];

    valueFactory1.factoryType = ALCFactoryTypeReference;

    ALCModelSearchCriteria *classCriteria = [ALCModelSearchCriteria searchCriteriaForClass:[TestRefClass1 class]];
    id<ALCResolvable> modelDependency = [[ALCModelDependency alloc] initWithCriteria:classCriteria];
    [valueFactory2 registerDependency:modelDependency forVariable:@"ref1"];

    [context start];

    id object = [[TestRefClass1 alloc] init];
    valueFactory1.object = object;

    XCTAssertTrue(valueFactory2.ready);
    XCTAssertNotNil(valueFactory2.object);

}

@end
