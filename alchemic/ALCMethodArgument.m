//
//  ALCArgument.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCMethodArgument.h>

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCStringMacros.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/ALCInjector.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodArgument

+(instancetype) argumentWithClass:(Class) argumentClass criteria:(id) firstCriteria, ... {
    alc_loadVarArgsIntoArray(firstCriteria, criteriaDefs);
    return [[ALCMethodArgument alloc] initWithArgumentClass:argumentClass criteria:criteriaDefs];
}

-(instancetype) initWithArgumentClass:(Class) aClass criteria:(NSArray *) criteria {
    id<ALCInjector> injector = [criteria injectionWithClass:aClass allowConstants:YES];
    self = [super initWithInjector:injector];
    if (self) {
    }
    return self;
}

-(instancetype) initWithInjector:(id<ALCInjector>) injector {
    methodReturningObjectNotImplemented;
}

-(NSString *) stackName {
    return str(@"arg %i", self.index);
}

-(ALCSimpleBlock) injectObject:(id) object {
    [self.injector setInvocation:object argumentIndex:self.index + 2];
    return NULL;
}

-(NSString *)resolvingDescription {
    return str(@"Argument %i", self.index);
}

@end

NS_ASSUME_NONNULL_END
