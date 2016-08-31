//
//  ALCArgument.m
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCMethodArgumentDependency.h>

#import <Alchemic/ALCType.h>
#import <Alchemic/ALCValueSource.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/ALCValue+Mapping.h>
#import <Alchemic/ALCValue+Injection.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodArgumentDependency

+(instancetype) methodArgumentWithType:(ALCType *) type criteria:firstCritieria, ... {
    
    alc_loadVarArgsIntoArray(firstCritieria, criteria);
    
    NSError *error;
    id<ALCValueSource> source = [criteria valueSourceForType:type
                                            constantsAllowed:YES
                                                       error:&error
                                             unknownArgument:^(id argument) {
                                                 throwException(AlchemicIllegalArgumentException, @"Unexpected argument %@", argument);
                                             }];
    return [[ALCMethodArgumentDependency alloc] initWithType:type valueSource:source];
}

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
            return;
        }
    }
    
    throwException(AlchemicInjectionException, @"Error injecting argument %lu: %@", _index, error.localizedDescription);
}

-(NSString *)resolvingDescription {
    return str(@"Argument %lu", _index);
}

@end

NS_ASSUME_NONNULL_END
