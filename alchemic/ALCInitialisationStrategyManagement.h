//
//  ALCInitialisationStrategyManagement.h
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;
@class ALCInitDetails;

/**
 Methods use to manage initialisation strategies.
 */
@protocol ALCInitialisationStrategyManagement <NSObject>

/**
 Called to perform the task of wrapping a classes init.
 
 @param class the class to wrap.
 @param context the context managing the objects.
 */
-(void) wrapInitInClass:(Class) class withContext:(ALCContext *) context;

/**
 Called when Alchemic is shutting down and needs to reset the runtime.
 */
-(void) resetClasses;

/**
 Returns the information for a replaced init.
 @discussion This is mainly used by the wrappers which need to call the original IMP as part of starting up.
 
 @param class the class whose init is needed.
 
 @return the IMP of the original init method.
 */
+(ALCInitDetails *) initDetailsForClass:(Class) class initSelector:(SEL) initSelector;

@end
