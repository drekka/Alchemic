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
 Called to resolve dependencies in an object.
 @param dependency the dependency info that specifies what needs to be resolved.
 @param object the object that needs the dependency.
 @param objectStore a ALCObjectStore of available objects.
 @return YES if all dependencies have been resolved. This stops the process of calling dependency resolvers.
 */
-(BOOL) resolveDependency:(ALCDependencyInfo *) dependency inObject:(id) object withObjectStore:(ALCObjectStore *) objectStore;

@end
