//
//  ALCObjectInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependencyInfo;

/**
 Protocol for classes that manage the onjection of dependencies into other objects.
 */
@protocol ALCDependencyResolver <NSObject>

/**
 Default initialiser
 
 @param context the ALCContext that owns the resolver.
 
 @return an instance of the resolver.
 */
-(instancetype) initWithModel:(NSDictionary *) model;

/**
 Called to resolve a dependency in an object.
 
 @param dependency the dependency info that specifies what needs to be resolved.
 @param object the object that needs the dependency.
 
 @return a list of candidate objects or nil if no met the criteria.
 */
-(id) resolveDependency:(ALCDependencyInfo *) dependency;

@end
