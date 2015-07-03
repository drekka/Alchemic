//
//  ALCVariableDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 26/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCDependency.h>
@import ObjectiveC;

@interface ALCVariableDependency : ALCDependency

@property (nonatomic, assign, readonly, nonnull) Ivar variable;

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                               variable:(Ivar __nonnull) variable
                               matchers:(NSSet<id<ALCMatcher>> __nonnull *) dependencyMatchers NS_DESIGNATED_INITIALIZER;

-(void) injectInto:(id __nonnull) object;

@end
