//
//  ALCRuntimeInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInitialisationStrategy.h"

@class ALCContext;

/**
 Protocol of classes that can perform injection of Alchemic startup code into the Objective C runtime.
 */
@protocol ALCInitialisationInjector <NSObject>

/**
 Adds a custom strategy to the list of initialisation strategies.
 */
-(void) addInitWrapperStrategy:(id<ALCInitialisationStrategy>) wrapperInitialisationStrategy;

/**
 Inject hooks into the runtime.
 */
-(void) addHooksToClasses:(NSArray *) classes withContext:(ALCContext *) context;

/**
 Reset the runtime back to it's original state.
 */
-(void) resetRuntime;

@end
