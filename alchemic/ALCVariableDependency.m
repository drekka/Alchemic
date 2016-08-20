//
//  ALCDependencyRef.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"
#import "ALCInjector.h"
#import "ALCStringMacros.h"
#import "ALCFlagMacros.h"
#import "ALCInternalMacros.h"
#import "ALCException.h"
#import "ALCRuntime.h"

@implementation ALCVariableDependency {
    Ivar _ivar;
}

-(instancetype) initWithInjector:(id<ALCInjector>) injector
                        intoIvar:(Ivar) ivar
                            name:(NSString *) name {
    self = [super initWithInjector:injector];
    if (self) {
        _ivar = ivar;
        _name = name;
    }
    return self;
}

+(instancetype) variableDependencyWithInjector:(id<ALCInjector>) injector
                                      intoIvar:(Ivar) ivar
                                          name:(NSString *) name {
    return [[ALCVariableDependency alloc] initWithInjector:injector intoIvar:ivar name:name];
}

-(void) configureWithOptions:(NSArray *) options {
    for (id option in options) {

        if ([option isKindOfClass:[ALCIsNillable class]]) {
            self.injector.allowNilValues = YES;
        
        } else if ([option isKindOfClass:[ALCIsTransient class]]) {
            _transient = YES;
            self.injector.allowNilValues = YES;
        
        } else {
           throwException(IllegalArgument, @"Unknown variable dependency option: %@", option);
        }
    }
}

-(NSString *)stackName {
    return _name;
}

-(ALCSimpleBlock)injectObject:(id)object {
    NSError *error;
    ALCSimpleBlock completionBlock = [self.injector setObject:object variable:_ivar error:&error];
    if (!completionBlock && error) {
        throwException(Injection, @"Error injecting %@: %@", [ALCRuntime class:[object class] variableDescription:_ivar], error.localizedDescription);
        return nil;
    }
    return completionBlock;
}

-(NSString *)resolvingDescription {
    return str(@"Variable %@", _name);
}

@end
