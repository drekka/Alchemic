//
//  ALCVariableInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 17/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependencyInfo;

/**
 Classes which can perform injections of dependencies into objects.
 */
@protocol ALCVariableInjector <NSObject>

/**
 Called to perform an injection into a target object.
 
 @param object     the object whose dependency needs to be injected.
 @param dependency a description of the dependency.
 @param candidates a list of candidate objects sourced from the dependency resolvers.
 
 @return YES if the dependency was injected.
 */
-(BOOL) injectIntoObject:(id) object dependency:(ALCDependencyInfo *) dependency candidates:(NSArray *) candidates;

@end
