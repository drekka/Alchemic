//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectInjector.h"
#import "ALCInitialisationInjector.h"

@interface ALCContext : NSObject

/**
 Specifies the class used to inject dependencies into objects.
 @discussion By default this is AlchemicObjectInjector.
 */
@property (nonatomic, assign) Class<ALCObjectInjector> objectInjectorClass;

/**
 Specifies the class used to inject dependencies into the runtime.
 @discussion By default this is AlchemicRuntimeInjector.
 */
@property (nonatomic, assign) Class<ALCInitialisationInjector> runtimeInjectorClass;

/**
 Called after init so that the code has time to changes setup before starting the context.
 */
-(void) start;

/**
 Registers a class which will need dependencies in the future.
 
 @param class the class which will need dependencies.
 @param inj   the name of the property, variable or property variable to be injected.
 */
-(void) registerInjection:(NSString *) inj inClass:(Class) class;

/**
 Registers a class as a singleton.
 
 @param singleton the class to be treated as a singleton.
 */
-(void) registerSingleton:(Class) singleton;

/**
 Injects dependencies into the passed object.
 
 @param object the object to have it's dependencies resolved.
 
 */
-(void) resolveDependencies:(id) object;

@end
