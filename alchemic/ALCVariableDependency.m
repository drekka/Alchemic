//
//  ALCDependencyRef.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"

#import "ALCException.h"
#import "ALCRuntime.h"
#import "ALCValue+Injection.h"
#import "ALCValueSource.h"

@implementation ALCVariableDependency {
    Ivar _ivar;
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

-(NSString *)stackName {
    return _name;
}

-(void) injectObject:(id) object {
    ALCValue *value = self.valueSource.value;
    if (value) {
        ALCVariableInjectorBlock injector = [value variableInjectorForType:self.type];
        NSError *error;
        if (!injector(object, self.type, _ivar, &error)) {
            throwException(AlchemicInjectionException, @"Error injecting value into variable %@: %@", [ALCRuntime forClass:[object class] propertyDescription:_name], error.localizedDescription);
        }
    }
}

-(NSString *)resolvingDescription {
    return str(@"Variable %@", _name);
}

@end
