//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;

#import <Alchemic/ALCQualifier.h>
#import <Alchemic/ALCDependencyPostProcessor.h>

@interface ALCDependency : NSObject

@property (nonatomic, strong, readonly, nonnull) id value;

@property (nonatomic, strong, readonly, nonnull) Class valueClass;

#pragma mark - Resolving

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> __nonnull *) postProcessors;

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                             qualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers;

@end
