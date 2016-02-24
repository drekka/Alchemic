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
#import "ALCInternalMacros.h"
#import "ALCDependencyStackItem.h"
#import "ALCDependency.h"

@implementation ALCClassObjectFactory {
    NSMutableArray<ALCDependencyRef *> *_dependencies;
}

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

-(void) resolveDependenciesWithStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack model:(id<ALCModel>) model {
    for (ALCDependencyRef *ref in _dependencies) {
        NSString *depDesc = str(@"%@.%@", NSStringFromClass(self.objectClass), ref.name);
        [self resolve:ref.dependency withStack:resolvingStack description:depDesc model:model];
     }
}

-(bool) ready {
    if (super.ready) {
        for (ALCDependencyRef *ref in _dependencies) {
            if (!ref.dependency.ready) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

-(id) instantiateObject {
    return [[self.objectClass alloc] init];
}

-(void) setObject:(id) object {
    [self injectDependenciesIntoObject:object];
    super.object = object;
}

-(void) injectDependenciesIntoObject:(id) value {
    for (ALCDependencyRef *depRef in _dependencies) {
        [depRef.dependency setObject:value variable:depRef.ivar];
    }
}

@end
