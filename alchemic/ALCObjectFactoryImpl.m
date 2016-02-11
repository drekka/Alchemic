//
//  ALCAbstractObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import ObjectiveC;

#import "ALCObjectFactoryImpl.h"
#import "ALCInstantiator.h"
#import "ALCTypeStrategy.h"
#import "ALCSingletonTypeStrategy.h"
#import "ALCFactoryTypeStrategy.h"
#import "ALCReferenceTypeStrategy.h"
#import "ALCRuntime.h"
#import "ALCClassInstantiator.h"
#import "NSObject+Alchemic.h"
#import "ALCDependencyStackItem.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCDependencyRef : NSObject
@property (nonatomic, assign) Ivar ivar;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) id<ALCResolvable> dependency;
@end

@implementation ALCDependencyRef
@end

@implementation ALCObjectFactoryImpl {
    id<ALCInstantiator> _instantiator;
    id<ALCTypeStrategy> _typeStrategy;
    NSMutableArray<ALCDependencyRef *> *_dependencies;
}

@synthesize factoryType = _factoryType;
@synthesize objectClass = _objectClass;
@dynamic resolved;

+(id<ALCObjectFactory>) NoFactoryInstance {
    static id<ALCObjectFactory> _NoFactoryInstance;
    if (!_NoFactoryInstance) {
        _NoFactoryInstance = [[ALCObjectFactoryImpl alloc] init];
    }
    return _NoFactoryInstance;
}

-(instancetype) initWithClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        [self setFactoryType:_factoryType];
        _dependencies = [[NSMutableArray alloc] init];
        _instantiator = [[ALCClassInstantiator alloc] init];
    }
    return self;
}

-(void)setFactoryType:(ALCFactoryType)factoryType {
    _factoryType = factoryType;
    switch (_factoryType) {
        case ALCFactoryTypeFactory:
            _typeStrategy = [[ALCFactoryTypeStrategy alloc] init];
            break;

        case ALCFactoryTypeReference:
            _typeStrategy = [[ALCReferenceTypeStrategy alloc] init];
            break;

        default:
            _typeStrategy = [[ALCSingletonTypeStrategy alloc] init];
            break;
    }
}

-(NSString *)defaultName {
    return NSStringFromClass(self.objectClass);
}

-(bool) resolved {
    if (!_typeStrategy.resolved) {
        return NO;
    }
    for (ALCDependencyRef *ref in _dependencies) {
        if (!ref.dependency.resolved) {
            return NO;
        }
    }
    return YES;
}

-(void) registerDependency:(id<ALCResolvable>) dependency forVariable:(NSString *) variableName {
    ALCDependencyRef *ref = [[ALCDependencyRef alloc] init];
    ref.ivar = [ALCRuntime aClass:self.objectClass variableForInjectionPoint:variableName];
    ref.name = variableName;
    ref.dependency = dependency;
    [_dependencies addObject:ref];
}

-(id) object {
    id object = _typeStrategy.object;
    if (!object) {
        object = [_instantiator instantiateForFactory:self];
        self.object = object;
    }
    return object;
}

-(void) setObject:(id) object {
    _typeStrategy.object = object;
    [self injectDependenciesIntoObject:object];
}

-(void) resolveWithStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack model:(id<ALCModel>) model {

    // Check for circular dependencies first.
    ALCDependencyStackItem *stackItem = [[ALCDependencyStackItem alloc] initWithObjectFactory:self description:NSStringFromClass(self.objectClass)];
    if ([resolvingStack containsObject:stackItem]) {
        [resolvingStack addObject:stackItem];

        @throw [NSException
                exceptionWithName:@"AlchemicCircularDependency"
                reason:str(@"Circular dependency detected: %@", [resolvingStack componentsJoinedByString:@" -> "])
                userInfo:nil];
    }

    // Exit if already resolved.
    if (self.resolved) {
        return;
    }

    // Pass through to dependencies.
    for (ALCDependencyRef *ref in _dependencies) {
        NSString *depDesc = str(@"%@.%@", NSStringFromClass(self.objectClass), ref.name);
        [resolvingStack addObject:[[ALCDependencyStackItem alloc] initWithObjectFactory:self description:depDesc]];
        [ref.dependency resolveWithStack:resolvingStack model:model];
        [resolvingStack removeLastObject];
    }
}

-(void) injectDependenciesIntoObject:(id) value {
    for (ALCDependencyRef *depRef in _dependencies) {
        [value injectVariable:depRef.ivar withResolvable:depRef.dependency];
    }
}

- (nonnull NSString *)description {
    NSString *instantiated = [_typeStrategy isKindOfClass:[ALCSingletonTypeStrategy class]] && _typeStrategy.object ? @"* " : @"  ";
    NSString *objectType;
    if ([_typeStrategy isKindOfClass:[ALCSingletonTypeStrategy class]]) {
        objectType = @"Singleton";
    } else if ([_typeStrategy isKindOfClass:[ALCReferenceTypeStrategy class]]) {
        objectType = @"Reference";
    } else {
        objectType = @"Factory";
    }
    NSString *appDelegate = [self.objectClass conformsToProtocol:@protocol(UIApplicationDelegate)] ? @" (App delegate)" : @"";
    return str(@"%@%@ %@%@", instantiated, objectType, NSStringFromClass(self.objectClass), appDelegate);
}

@end

NS_ASSUME_NONNULL_END

