//
//  ALCAbstractObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import ObjectiveC;

#import "ALCAbstractObjectFactory.h"
#import "ALCInstantiator.h"
#import "ALCObjectFactoryType.h"
#import "ALCObjectFactoryTypeSingleton.h"
#import "ALCObjectFactoryTypeFactory.h"
#import "ALCObjectFactoryTypeReference.h"
#import "ALCRuntime.h"
#import "ALCClassInstantiator.h"
#import "NSObject+Alchemic.h"
#import "ALCDependencyStackItem.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN


@implementation ALCAbstractObjectFactory {
    id<ALCInstantiator> _instantiator;
    id<ALCObjectFactoryType> _typeStrategy;
}

@synthesize factoryType = _factoryType;
@synthesize objectClass = _objectClass;
@dynamic resolved;

-(instancetype) initWithClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        [self setFactoryType:_factoryType];
        _instantiator = [[ALCClassInstantiator alloc] init];
    }
    return self;
}

-(void)setFactoryType:(ALCFactoryType)factoryType {
    _factoryType = factoryType;
    switch (_factoryType) {
        case ALCFactoryTypeFactory:
            _typeStrategy = [[ALCObjectFactoryTypeFactory alloc] init];
            break;

        case ALCFactoryTypeReference:
            _typeStrategy = [[ALCObjectFactoryTypeReference alloc] init];
            break;

        default:
            _typeStrategy = [[ALCObjectFactoryTypeSingleton alloc] init];
            break;
    }
}

-(NSString *)defaultName {
    return NSStringFromClass(self.objectClass);
}

-(bool) resolved {
    return _typeStrategy.resolved;
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
}

- (nonnull NSString *)description {
    NSString *instantiated = [_typeStrategy isKindOfClass:[ALCSingletonTypeStrategy class]] && _typeStrategy.object ? @"* " : @"  ";
    NSString *objectType;
    if ([_typeStrategy isKindOfClass:[ALCObjectFactoryTypeSingleton class]]) {
        objectType = @"Singleton";
    } else if ([_typeStrategy isKindOfClass:[ALCObjectFactoryTypeReference class]]) {
        objectType = @"Reference";
    } else {
        objectType = @"Factory";
    }
    NSString *appDelegate = [self.objectClass conformsToProtocol:@protocol(UIApplicationDelegate)] ? @" (App delegate)" : @"";
    return str(@"%@%@ %@%@", instantiated, objectType, NSStringFromClass(self.objectClass), appDelegate);
}

@end

NS_ASSUME_NONNULL_END

