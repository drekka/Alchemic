//
//  MethodFactories.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
#import "ALCContext.h"
#import "ALCContextImpl.h"
#import "ALCObjectFactory.h"
#import "ALCClassObjectFactory.h"
#import "ALCMethodObjectFactory.h"
#import "ALCModelSearchCriteria.h"
#import "ALCResolvable.h"

@interface TestMFClass : NSObject
@end

@implementation TestMFClass

-(NSString *) simpleCreate {
    return @"abc";
}

@end

@interface MethodFactories : XCTestCase
@end

@implementation MethodFactories{
    id<ALCContext> context;
}

-(void) setUp {
    context = [[ALCContextImpl alloc] init];
}

-(void) testSimpleFactoryMethod {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestMFClass class]];
    ALCMethodObjectFactory *methodFactory = [context registerMethod:@selector(simpleCreate)
                                                parentObjectFactory:valueFactory
                                                               args:nil
                                                         returnType:[NSString class]];

    [context start];

    XCTAssertNotNil(methodFactory.object);
}

@end
