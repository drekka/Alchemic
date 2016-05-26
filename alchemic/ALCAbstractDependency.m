//
//  ALCAbstractDependencyDecorator.m
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCAbstractDependency.h>

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCInjector.h>

@implementation ALCAbstractDependency

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithInjector:(id<ALCInjector>) injector {
    self = [super init];
    if (self) {
        _injector = injector;
    }
    return self;
}

#pragma mark - ALCResolvable

-(BOOL)ready {
    return _injector.ready;
}

-(Class)objectClass {
    return _injector.objectClass;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                   model:(id<ALCModel>)model {
    [_injector resolveWithStack:resolvingStack model:model];
}

-(NSString *)resolvingDescription {
    methodNotImplemented;
    return @"";
}

#pragma mark - ALCDependency

-(NSString *)stackName {
    methodNotImplemented;
    return @"";
}

-(ALCSimpleBlock)injectObject:(id)object {
    methodReturningBlockNotImplemented;
}

@end
