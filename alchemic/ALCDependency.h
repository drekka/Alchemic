//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;

#import "ALCMatcher.h"
#import "ALCResolvable.h"

@interface ALCDependency : NSObject<ALCResolvable>

-(instancetype) initWithContext:(__weak ALCContext *) context
                      valueType:(ALCType *) valueType
                       matchers:(NSSet *) dependencyMatchers;

@end
