//
//  ALCDependencyRef.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependency.h"
#import "ALCinjection.h"

@implementation ALCVariableDependency {
    Ivar _ivar;
    NSString *_name;
}

-(instancetype) initWithInjection:(id<ALCInjection>) injection
                         intoIvar:(Ivar) ivar
                             name:(NSString *) name {
    self = [super initWithInjection:injection];
    if (self) {
        _ivar = ivar;
        _name = name;
    }
    return self;
}

+(instancetype) variableDependencyWithInjection:(id<ALCDependency, ALCInjection>) injection
                                       intoIvar:(Ivar) ivar
                                           name:(NSString *) name {
    return [[ALCVariableDependency alloc] initWithInjection:injection intoIvar:ivar name:name];
}

-(NSString *)stackName {
    return _name;
}

-(ALCSimpleBlock)injectObject:(id)object {
    return [self.injection setObject:object variable:_ivar];
}

@end
