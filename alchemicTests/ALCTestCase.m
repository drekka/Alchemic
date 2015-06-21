//
//  ALCTestCase.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import "ALCLogger.h"
#import "Alchemic.h"

@implementation ALCTestCase

+(void)load {
    [ALCLogger turnOnAllLogging];
    [ALCLogger stopLogging:AlchemicLogCategoryRuntime];
}

- (void)setUp {
    injectDependencies(self);
}

@end
