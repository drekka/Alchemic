//
//  ALCTestCase.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>

@interface ALCTestCase : XCTestCase

@property (nonatomic, strong, readonly, nullable) ALCContext *context;

-(void) setUpALCContext;

-(void) scanClassIntoContext:(Class __nonnull) aClass;

@end
