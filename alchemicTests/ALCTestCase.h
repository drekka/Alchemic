//
//  ALCTestCase.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>
@protocol ALCMacroProcessor;

NS_ASSUME_NONNULL_BEGIN

@interface ALCTestCase : XCTestCase

@property (nonatomic, strong, readonly, nullable) ALCContext *context;

-(void) mockAlchemicContext;

-(void) setUpALCContextWithClasses:(NSArray<Class> *) classes;

-(void) loadMacroProcessor:(id<ALCMacroProcessor>) macroProcessor withArguments:(id __nullable) firstArgument, ... NS_REQUIRES_NIL_TERMINATION;

@end

NS_ASSUME_NONNULL_END