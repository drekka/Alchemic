//
//  AlchemicRuntimeInjectorTests.m
//  alchemic
//
//  Created by Derek Clarkson on 17/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"

#import "ALCInitialisationStrategyInjector.h"

@interface AlchemicRuntimeInjectorTests : ALCTestCase

@end

@implementation AlchemicRuntimeInjectorTests

-(void) testRuntimeNSObjectInit {
    [[NSObject alloc] init];
}

@end
