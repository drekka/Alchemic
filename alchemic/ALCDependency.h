//
//  ALCDependency.h
//  Alchemic
//
//  Created by Derek Clarkson on 21/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCResolvable.h>

@protocol ALCObjectFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 Dependencies define the the values that ALCInjector instances need to perform injections.
 */
@protocol ALCDependency <ALCResolvable>

/**
 The name of the dependency for displaying in resolving stacks.
 */
@property (nonatomic, strong, readonly) NSString *stackName;

/**
 Returns YES if the dependency references at least one object factory that is set as transient.
 */
@property (nonatomic, assign, readonly) BOOL referencesTransients;

/**
 Single access point for triggering injects.
 
 @param object The object to inject. Usually a object or NSInvocation.
 */
-(void) injectObject:(id) object;

/**
 Returns YES if the passed object factory is referenced by this injector.

 @discussion This is a facade method to provide access to the same method on the dependencies internal injector.
 
 @param objectFactory The object factory to query for.
 */
-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory;

@end

NS_ASSUME_NONNULL_END
