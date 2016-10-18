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
#import <Alchemic/ALCValue+Injection.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodArgumentDependency

+(instancetype) methodArgumentWithType:(ALCType *) type criteria:firstCritieria, ... {
    alc_loadVarArgsIntoArray(firstCritieria, criteria);
    return [self methodArgumentWithType:type argumentCriteria:criteria];
}

+(instancetype) methodArgumentWithType:(ALCType *) type argumentCriteria:(NSArray *) criteria {

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
    return str(@"arg %lu",  (unsigned long) _index);
}

-(void) injectObject:(id) object {
    ALCValue *value = self.valueSource.value;
    if (value) {
        ALCInvocationInjectorBlock injector = [value invocationInjectorForType:self.type];
        NSError *error;
        if (!injector(object, self.type, (NSInteger) _index, &error)) {
            throwException(AlchemicInjectionException, @"Error injecting value at index %lu: %@", (unsigned long)_index, error.localizedDescription);
        }
        return;
    }
}

-(NSString *)resolvingDescription {
    return str(@"Argument %lu",  (unsigned long) _index);
}

@end

NS_ASSUME_NONNULL_END
