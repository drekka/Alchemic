//
//  ALCDependencyRef.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCVariableDependency.h>

#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCRuntime.h>
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

        } else {
            throwException(AlchemicIllegalArgumentException, @"Unknown variable dependency option: %@", option);
        }
    }
}

-(NSString *)stackName {
    return _name;
}

-(void) injectObject:(id)object {
    ALCValue *value = self.valueSource.value;
    if (value) {
        ALCVariableInjectorBlock injector = [value variableInjectorForType:self.type.type];
        injector(object, _ivar);
        return;
    }
}

-(NSString *)resolvingDescription {
    return str(@"Variable %@", _name);
}

@end
