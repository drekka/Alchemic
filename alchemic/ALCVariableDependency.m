//
//  ALCDependencyRef.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCVariableDependency.h>
#import <Alchemic/ALCInjector.h>
#import <Alchemic/ALCStringMacros.h>

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

+(instancetype) variableDependencyWithInjector:(id<ALCDependency, ALCInjector>) injector
                                      intoIvar:(Ivar) ivar
                                          name:(NSString *) name {
    return [[ALCVariableDependency alloc] initWithInjector:injector intoIvar:ivar name:name];
}

-(BOOL) transient {
    return self.injector;
}

-(NSString *)stackName {
    return _name;
}

-(ALCSimpleBlock)injectObject:(id)object {
    return [self.injector setObject:object variable:_ivar];
}

-(NSString *)resolvingDescription {
    return str(@"Variable %@", _name);
}

@end
