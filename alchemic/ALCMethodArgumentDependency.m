//
//  ALCArgument.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCMethodArgumentDependency.h"

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCStringMacros.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/ALCValue+Mapping.h>
#import <Alchemic/ALCValue+Injection.h>
#import <Alchemic/ALCValueSource.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodArgumentDependency

-(NSString *) stackName {
    return str(@"arg %lu", _index);
}

-(void) injectObject:(id) object {

    NSError *error;
    ALCValue *value = [self.valueSource valueWithError:&error];
    if (value) {

        ALCValue *finalValue = [value mapTo:self.type error:&error];
        if (finalValue) {
            ALCInvocationInjectorBlock injector = [finalValue invocationInjector];
            injector(object, (NSInteger) _index);
        }
    }

    throwException(Injection, @"Error injecting argument %lu: %@", _index, error.localizedDescription);
}

-(NSString *)resolvingDescription {
    return str(@"Argument %lu", _index);
}

@end

NS_ASSUME_NONNULL_END
