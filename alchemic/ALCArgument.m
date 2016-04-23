//
//  ALCArgument.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCArgument.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "NSArray+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCArgument ()
-(instancetype) initWithDependency:(id<ALCDependency>) dependency;
@end

ALCArgument * AcArgument(Class argumentClass, id firstCriteria, ...) {
    alc_loadVarArgsIntoArray(firstCriteria, criteriaDefs);
    return [[ALCArgument alloc] initWithDependency:[criteriaDefs dependencyWithClass:argumentClass]];
}

@implementation ALCArgument

+(instancetype) argumentWithClass:(Class) argumentClass criteria:(id) firstCriteria, ... {
    alc_loadVarArgsIntoArray(firstCriteria, criteriaDefs);
    return [[ALCArgument alloc] initWithDependency:[criteriaDefs dependencyWithClass:argumentClass]];
}

-(instancetype) initWithDependency:(id<ALCDependency>) dependency {
    self = [super init];
    if (self) {
        _dependency = dependency;
    }
    return self;
}

@end

NS_ASSUME_NONNULL_END
