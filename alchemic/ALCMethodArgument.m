//
//  ALCArgument.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCMethodArgument.h"

#import "ALCInternalMacros.h"
#import "NSArray+Alchemic.h"
#import "ALCInjection.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodArgument

+(instancetype) argumentWithClass:(Class) argumentClass criteria:(id) firstCriteria, ... {
    alc_loadVarArgsIntoArray(firstCriteria, criteriaDefs);
    id<ALCInjection> injection = [criteriaDefs injectionWithClass:argumentClass allowConstants:YES];
    return [[ALCMethodArgument alloc] initWithInjection:injection];
}

-(NSString *) stackName {
    return str(@"arg %i", self.index);
}

-(ALCSimpleBlock) injectObject:(id) object {
    [self.injection setInvocation:object argumentIndex:self.index + 2];
    return NULL;
}

@end

NS_ASSUME_NONNULL_END
