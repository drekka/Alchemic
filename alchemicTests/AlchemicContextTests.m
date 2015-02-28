//
//  AlchemicContext.m
//  alchemic
//
//  Created by Derek Clarkson on 16/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "Alchemic.h"
#import "ALCContext.h"
#import "InjectableObject.h"
#import "ALCLogger.h"
#import "ALCTestCase.h"

@interface AlchemicContextTests : ALCTestCase

@end

@implementation AlchemicContextTests

-(void) testContextPresent {
    SEL mainContextSelector = NSSelectorFromString(@"mainContext");
    ALCContext *context = ((ALCContext *(*)(id, SEL))objc_msgSend)([Alchemic class], mainContextSelector);
    XCTAssertNotNil(context);
}

-(void) testRegisteringASingleton {
    ALCContext *context = [[ALCContext alloc] init];
    [context registerSingleton:[InjectableObject class]];
}

@end
