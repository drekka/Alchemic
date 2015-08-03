//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCDependencyPostProcessor;
@protocol ALCValueSource;
#import "ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Main class for managing dependencies.
 */
@interface ALCDependency : NSObject<ALCResolvable>

@property (nonatomic, strong, readonly) id value;

@property (nonatomic, strong, readonly) Class valueClass;

#pragma mark - Resolving

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors;

-(instancetype) initWithValueClass:(Class) valueClass
                       valueSource:(id<ALCValueSource>) valueSource;

@end

NS_ASSUME_NONNULL_END