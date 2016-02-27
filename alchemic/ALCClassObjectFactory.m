//
//  ALCClassObjectFactory.m
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCClassObjectFactory.h"
#import "ALCDependencyRef.h"
#import "ALCRuntime.h"
#import "NSObject+Alchemic.h"
#import "NSMutableArray+Alchemic.h"
#import "ALCInternalMacros.h"
#import "ALCDependency.h"
#import "ALCClassObjectFactoryInitializer.h"

@implementation ALCClassObjectFactory {
    NSMutableArray<ALCDependencyRef *> *_dependencies;
    BOOL _checkingReadyStatus;
}

@synthesize initializer = _initializer;

-(instancetype) initWithClass:(Class) objectClass {
    self = [super initWithClass:objectClass];
    if (self) {
        _dependencies = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) registerDependency:(id<ALCDependency>) dependency forVariable:(NSString *) variableName {
    ALCDependencyRef *ref = [[ALCDependencyRef alloc] init];
    ref.ivar = [ALCRuntime aClass:self.objectClass variableForInjectionPoint:variableName];
    ref.name = variableName;
    ref.dependency = dependency;
    [_dependencies addObject:ref];
}

-(void) resolveDependenciesWithStack:(NSMutableArray<NSString *> *) resolvingStack model:(id<ALCModel>) model {

    // Resolve the initializer.
    if (_initializer) {
        [resolvingStack resolve:_initializer model:model];
    }

    for (ALCDependencyRef *ref in _dependencies) {
        NSString *depDesc = str(@"%@.%@", NSStringFromClass(self.objectClass), ref.name);
        [resolvingStack resolve:ref.dependency resolvableName:depDesc model:model];
     }
}

-(BOOL) ready {

    if (_checkingReadyStatus) {
        return YES;
    }
    _checkingReadyStatus = YES;

    BOOL ready = super.ready;
    if (ready) {
        for (ALCDependencyRef *ref in _dependencies) {
            if (!ref.dependency.ready) {
                ready = NO;
                break;
            }
        }
    }
    _checkingReadyStatus = NO;
    return ready;
}

-(id) instantiateObject {
    return [[self.objectClass alloc] init];
}

-(void) setObject:(id) object {
    super.object = object;
    [self injectDependenciesIntoObject:object];
}

-(void) injectDependenciesIntoObject:(id) value {
    for (ALCDependencyRef *depRef in _dependencies) {
        [depRef.dependency setObject:value variable:depRef.ivar];
    }
}

@end
