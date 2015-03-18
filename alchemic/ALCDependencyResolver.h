//
//  ALCObjectInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;
@class ALCDependencyInfo;
@class ALCObjectStore;

/**
 Protocol for classes that manage the onjection of dependencies into other objects.
 */
@protocol ALCDependencyResolver <NSObject>

/**
 Default initialiser
 
 @param context the ALCContext that owns the resolver.
 
 @return an instance of the resolver.
 */
-(instancetype) initWithContext:(__weak ALCContext *) context;

/**
 Called to resolve a dependency in an object.
 
 @param dependency the dependency info that specifies what needs to be resolved.
 @param object the object that needs the dependency.
 @param objectStore a ALCObjectStore of available objects.
 
 @return a list of candidate objects or nil if no met the criteria.
 */
-(NSArray *) resolveDependency:(ALCDependencyInfo *) dependency inObject:(id) object withObjectStore:(ALCObjectStore *) objectStore;

@end
