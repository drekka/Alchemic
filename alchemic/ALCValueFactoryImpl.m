//
//  ALCAbstractObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCValueFactoryImpl.h"
#import "ALCInstantiator.h"
#import "ALCTypeStrategy.h"
#import "ALCSingletonTypeStrategy.h"
#import "ALCFactoryTypeStrategy.h"
#import "ALCReferenceTypeStrategy.h"
#import "ALCRuntime.h"
#import "ALCDependency.h"
#import "ALCClassInstantiator.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCDependencyRef : NSObject
@property (nonatomic, assign) Ivar ivar;
@property (nonatomic, strong) ALCDependency *dependency;
@end

@implementation ALCDependencyRef
@end

@implementation ALCValueFactoryImpl {
    id<ALCInstantiator> _instantiator;
    id<ALCTypeStrategy> _typeStrategy;
    NSMutableArray<ALCDependencyRef *> *_dependencies;
}

@synthesize factoryType = _factoryType;
@synthesize valueClass = _valueClass;
@dynamic resolved;

+(id<ALCValueFactory>) NoFactoryInstance {
    static id<ALCValueFactory> _NoFactoryInstance;
    if (!_NoFactoryInstance) {
        _NoFactoryInstance = [[ALCValueFactoryImpl alloc] init];
    }
    return _NoFactoryInstance;
}

-(instancetype) initWithClass:(Class) valueClass {
    self = [super init];
    if (self) {
        _valueClass = valueClass;
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
    return NSStringFromClass([self class]);
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

-(void) addVariable:(NSString *) variableName dependency:(ALCDependency *) dependency {
    ALCDependencyRef *ref = [[ALCDependencyRef alloc] init];
    ref.ivar = [ALCRuntime aClass:self.valueClass variableForInjectionPoint:variableName];
    ref.dependency = dependency;
    [_dependencies addObject:ref];
}

-(id) value {
    id value = _typeStrategy.value;
    if (!value) {
        value = [_instantiator instantiateForFactory:self];
        self.value = value;
    }
    return value;
}

-(void) setValue:(id) value {
    _typeStrategy.value = value;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCValueFactory>> *) resolvingStack model:(id<ALCModel>) model {

    // Check for circular dependencies first.
    if ([resolvingStack containsObject:self]) {

        [resolvingStack addObject:self];
        @throw [NSException
                exceptionWithName:@"AlchemicCircularDependency"
                reason:[NSString stringWithFormat:@"Circular dependency detected: %@", [resolvingStack componentsJoinedByString:@" -> "]]
                userInfo:nil];
    }

    // Exit if already resolved.
    if (self.resolved) {
        return;
    }

    // Pass through to dependencies.
    [resolvingStack addObject:self];
    for (ALCDependencyRef *ref in _dependencies) {
        [ref.dependency resolveWithStack:resolvingStack model:model];
    }
    [resolvingStack removeLastObject];
}

@end

NS_ASSUME_NONNULL_END

