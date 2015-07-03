//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;

#import <Alchemic/ALCMatcher.h>

@interface ALCDependency : NSObject

@property (nonatomic, strong, readonly, nonnull) id value;

@property (nonatomic, strong, readonly, nonnull) Class valueClass;

#pragma mark - Resolving

-(void) resolve;

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                               matchers:(NSSet<id<ALCMatcher>> __nullable *) dependencyMatchers;

@end
