//
//  ALCContext+Internal.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
@protocol ALCValueResolver;
@protocol ALCModelSearchExpression;

#define ProcessBuiderBlockArgs NSSet<id<ALCBuilder>> __nonnull *builders
typedef void (^ProcessBuilderBlock)(ProcessBuiderBlockArgs);

/**
 Category which gives access to methods reserved for internal Alchemic processing.
 */

NS_ASSUME_NONNULL_BEGIN

@interface ALCContext (Internal)

@property (nonatomic, strong, readonly) id<ALCValueResolver> valueResolver;

#pragma mark - Working with builders

-(void) addBuilderToModel:(id<ALCBuilder>) builder;

-(void) executeOnBuildersWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions
                       processingBuildersBlock:(ProcessBuilderBlock) processBuildersBlock;

-(id) instantiateObjectFromBuilder:(id<ALCBuilder>) builder;

#pragma mark - Resolving

-(void) resolveBuilderDependencies;

#pragma mark - Registration call backs

-(void) registerDependencyInClassBuilder:(ALCClassBuilder *) classBuilder, ...;

-(void) registerClassBuilder:(ALCClassBuilder *) classBuilder, ...;

@end

NS_ASSUME_NONNULL_END
