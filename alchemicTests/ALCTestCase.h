//
//  ALCTestCase.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import <Alchemic/Alchemic.h>
#import "ALCAbstractMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCTestCase : XCTestCase

@property (nonatomic, strong, readonly, nullable) ALCContext *context;

-(void) mockAlchemicContext;

-(void) setUpALCContextWithClasses:(NSArray<Class> *) classes;

-(void) loadMacroProcessor:(ALCAbstractMacroProcessor *) macroProcessor withArguments:(id __nullable) firstArgument, ...;

@end

NS_ASSUME_NONNULL_END