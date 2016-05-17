//
//  ALCAbstractDependencyDecorator.m
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractDependency.h"

#import "ALCInternalMacros.h"
#import "ALCInjector.h"

@implementation ALCAbstractDependency

-(instancetype) init {
    [self doesNotRecognizeSelector:@selector(init)];
    return nil;
}

-(instancetype) initWithInjection:(id<ALCInjector>) injection {
    self = [super init];
    if (self) {
        _injection = injection;
    }
    return self;
}

#pragma mark - ALCResolvable

-(bool)ready {
    return _injection.ready;
}

-(Class)objectClass {
    return _injection.objectClass;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                   model:(id<ALCModel>)model {
    [_injection resolveWithStack:resolvingStack model:model];
}

-(NSString *)resolvingDescription {
    methodReturningObjectNotImplemented;
}

#pragma mark - ALCDependency

-(NSString *)stackName {
    methodReturningObjectNotImplemented;
}

-(ALCSimpleBlock)injectObject:(id)object {
    methodReturningBlockNotImplemented;
}

@end
