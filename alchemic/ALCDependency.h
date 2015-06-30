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

@property (nonatomic, strong, readonly) id value;

@property (nonatomic, strong, readonly) ALCType *valueType;

#pragma mark - Resolving

-(void) resolve;

-(instancetype) initWithContext:(__weak ALCContext *) context
                      valueType:(ALCType *) valueType
                       matchers:(NSSet<id<ALCMatcher>> *) dependencyMatchers;

@end
