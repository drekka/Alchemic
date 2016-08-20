//
//  ALCArgument.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCMethodArgumentDependency.h"

#import "ALCInternalMacros.h"
#import "ALCStringMacros.h"
#import "NSArray+Alchemic.h"
#import "ALCInjector.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodArgumentDependency

+(instancetype) argumentWithClass:(Class) argumentClass criteria:(id) firstCriteria, ... {
    alc_loadVarArgsIntoArray(firstCriteria, criteriaDefs);
    return [[ALCMethodArgumentDependency alloc] initWithArgumentClass:argumentClass criteria:criteriaDefs];
}

-(instancetype) initWithArgumentClass:(Class) aClass criteria:(NSArray *) criteria {
    id<ALCInjector> injector = [criteria injectorForClass:aClass allowConstants:YES unknownArgumentHandler:NULL];
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
    NSError *error;
    if (![self.injector setInvocation:object argumentIndex:self.index error:&error]) {
        throwException(Injection, @"Error injecting argument %i: %@", self.index, error.localizedDescription);
    }
    
    return NULL;
}

-(NSString *)resolvingDescription {
    return str(@"Argument %i", self.index);
}

@end

NS_ASSUME_NONNULL_END
