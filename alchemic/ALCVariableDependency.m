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

-(NSString *)stackName {
    return _name;
}

-(ALCSimpleBlock)injectObject:(id)object {
    return [self.injector setObject:object variable:_ivar];
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                   model:(id<ALCModel>)model {
    [super resolveWithStack:resolvingStack model:model];
    if (self.transient) {
        [self.injector watch:^(id  _Nullable oldValue, id  _Nullable newValue) {
            self injectObject:(id) objectå∫
        }];
    }
}

-(NSString *)resolvingDescription {
    return str(@"Variable %@", _name);
}

@end
