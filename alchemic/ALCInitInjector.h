//
//  ALCRuntimeInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCInitStrategy.h>
#import <Alchemic/ALCBuilder.h>

@class ALCModel;

/**
 Protocol of classes that can perform injection of Alchemic startup code into the Objective C runtime.
 */
@protocol ALCInitInjector <NSObject>

/**
 Main initialiser.
 
 @param strategies A list of strategies to employ.
 */
-(instancetype) initWithStrategyClasses:(NSSet<id<ALCInitStrategy>> *) strategyClasses;

/**
 Inject hooks into the runtime.
 */
-(void) replaceInitsInModelClasses:(ALCModel *) model;

/**
 Reset the runtime back to it's original state.
 */
-(void) resetRuntime;

@end
