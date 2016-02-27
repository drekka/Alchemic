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
#import "ALCInternalMacros.h"
#import "ALCConstants.h"

@interface TestMFClass : NSObject
@property (nonatomic, assign) int aInt;
@property (nonatomic, strong) NSString *aString;
@end

@implementation TestMFClass

-(NSString *) simpleCreate {
    return @"abc";
}

-(instancetype) initWithString:(NSString *) aString andInt:(int) aInt {
    self = [super init];
    if (self) {
        _aInt = aInt;
        _aString = aString;
    }
    return self;
}

-(NSString *) createWithString:(NSString *) aString andInt:(int) aInt {
    return str(@"def %@ %i",aString, aInt);
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
                                                               args:@[]
                                                         returnType:[NSString class]];

    [context start];

    XCTAssertEqual(@"abc", methodFactory.object);
}

-(void) testFactoryMethodWithArgs {

    ALCClassObjectFactory *valueFactory = [context registerClass:[TestMFClass class]];
    id<ALCDependency> arg1 = ALCString(@"ghi");
    id<ALCDependency> arg2 = ALCInt(12);
    ALCMethodObjectFactory *methodFactory = [context registerMethod:@selector(createWithString:andInt:)
                                                parentObjectFactory:valueFactory
                                                               args:@[arg1, arg2]
                                                         returnType:[NSString class]];

    [context start];

    NSString *result = methodFactory.object;
    XCTAssertEqualObjects(@"def ghi 12", result);
}

@end
