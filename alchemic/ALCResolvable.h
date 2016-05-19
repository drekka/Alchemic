//
//  ALCResolvable.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCModel;

NS_ASSUME_NONNULL_BEGIN

/**
 Resolvables are objects that can be resolve their dependencies and be resolved as a dependency of another object.
 */
@protocol ALCResolvable <NSObject>

/**
 YES if the resolvable is resolved and ready to be used. For example, a factory that is ready to supply values.
 */
@property (nonatomic, assign, readonly) bool ready;

/**
 The class that the resolvable represents. This is used when the model is being serached.
 */
@property (nonatomic, assign, readonly) Class objectClass;

/**
 A decription of the resolvable used when reporting resolving stack information. Normally when debugging.
 */
@property (nonatomic, strong, readonly) NSString *resolvingDescription;

/**
 Tells the resolvable to resolve all it's dependencies.
 
 @param resolvingStack A stack of the resolvables currently resolving. This is used for circular dependency detection.
 @param model          The model that can be searched for dependencies.
 */
-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                   model:(id<ALCModel>)model;

@end

NS_ASSUME_NONNULL_END
