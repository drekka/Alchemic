//
//  ALCDependencyRef.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"

#import <Alchemic/ALCStringMacros.h>
#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCValue+Mapping.h>
#import <Alchemic/ALCValue+Injection.h>
#import <Alchemic/ALCValueSource.h>

@implementation ALCVariableDependency {
    Ivar _ivar;
    BOOL _allowNil;
}

-(instancetype) initWithType:(ALCType *) type
                 valueSource:(id<ALCValueSource>) valueSource
                    intoIvar:(Ivar) ivar
                    withName:(NSString *) name {
    self = [super initWithType:type valueSource:valueSource];
    if (self) {
        _ivar = ivar;
        _name = name;
    }
    return self;
}

+(instancetype) variableDependencyWithType:(ALCType *) type
                               valueSource:(id<ALCValueSource>) valueSource
                                  intoIvar:(Ivar) ivar
                                  withName:(NSString *) name {
    return [[ALCVariableDependency alloc] initWithType:type
                                           valueSource:valueSource
                                              intoIvar:ivar
                                              withName:name];
}

-(void) configureWithOptions:(NSArray *) options {
    for (id option in options) {

        if ([option isKindOfClass:[ALCIsNillable class]]) {
            _allowNil = YES;

        } else if ([option isKindOfClass:[ALCIsTransient class]]) {
            _transient = YES;
            _allowNil = YES;

        } else {
            throwException(IllegalArgument, @"Unknown variable dependency option: %@", option);
        }
    }
}

-(NSString *)stackName {
    return _name;
}

-(void) injectObject:(id)object {

    NSError *error;
    ALCValue *value = [self.valueSource valueWithError:&error];
    if (value) {

        ALCValue *finalValue = [value mapTo:self.type error:&error];
        if (finalValue) {
            ALCVariableInjectorBlock injector = [finalValue variableInjector];
            injector(object, _ivar);
        }
    }

    throwException(Injection, @"Error injecting %@: %@", [ALCRuntime forClass:[object class] variableDescription:_ivar], error.localizedDescription);
}

-(NSString *)resolvingDescription {
    return str(@"Variable %@", _name);
}

@end
