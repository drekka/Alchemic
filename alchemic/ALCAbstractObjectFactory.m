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
#import "ALCObjectFactoryType.h"
#import "ALCObjectFactoryTypeSingleton.h"
#import "ALCObjectFactoryTypeFactory.h"
#import "ALCObjectFactoryTypeReference.h"
#import "ALCRuntime.h"
#import "NSObject+Alchemic.h"
#import "ALCDependencyStackItem.h"
#import "ALCInternalMacros.h"
#import "ALCModel.h"
#import "ALCDependency.h"

NS_ASSUME_NONNULL_BEGIN


@implementation ALCAbstractObjectFactory {
    id<ALCObjectFactoryType> _typeStrategy;
    bool _resolved;
    SimpleBlock _readyBlock;
}

@synthesize factoryType = _factoryType;
@synthesize objectClass = _objectClass;

#pragma mark - Property overrides

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

-(id) object {
    id object = _typeStrategy.object;
    if (!object) {
        object = [self instantiateObject];
        self.object = object;
    }
    return object;
}

-(void) setObject:(id) object {

    // If dependencies are not resolved then the value cannot be set.
    if (!_resolved) {
        throwException(@"AlchemicDependenciesNotResolved", @"Cannot set object, dependencies not resolved");
    }

    _typeStrategy.object = object;
    if (_readyBlock != NULL) {
        _readyBlock();
        _readyBlock = NULL;
    }
}

-(bool) ready {
    return _typeStrategy.ready;
}

-(NSString *) defaultName {
    return NSStringFromClass(self.objectClass);
}

-(NSString *) descriptionAttributes {
    return self.defaultName;
}

-(NSString *) description {

    NSMutableString *description = [[NSMutableString alloc] init];

    switch (_factoryType) {
        case ALCFactoryTypeFactory:
            [description appendString:_typeStrategy.object ? @"* " : @"  "];
            [description appendString:@"Factory "];
            break;

        case ALCFactoryTypeReference:
            [description appendString:@"  Reference "];
            break;

        default:
            [description appendString:@"  Singleton "];
    }

    [description appendString:self.descriptionAttributes];

    if ([self.objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        [description appendString:@" (App delegate)"];
    }

    return description;
}

#pragma mark - Lifecycle

-(instancetype) initWithClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        [self setFactoryType:_factoryType];
    }
    return self;
}


-(id) instantiateObject {
    return nil;
}

-(void) resolveWithStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack model:(id<ALCModel>) model {

    if (_resolved) {
        return;
    }

    // Check for circular dependencies first.
    ALCDependencyStackItem *stackItem = [[ALCDependencyStackItem alloc] initWithObjectFactory:self description:NSStringFromClass(self.objectClass)];
    if ([resolvingStack containsObject:stackItem]) {
        [resolvingStack addObject:stackItem];
        throwException(@"AlchemicCircularDependency", @"Circular dependency detected: %@", [resolvingStack componentsJoinedByString:@" -> "]);
    }

    [self resolveDependenciesWithStack:resolvingStack model:model];
    if (!self.ready) {
        blockSelf;
        _readyBlock = ^{
            [model objectFactoryReady:strongSelf];
        };
    }

    _resolved = YES;
}

-(void) resolveDependenciesWithStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack
                               model:(id<ALCModel>) model {}

-(void) resolve:(id<ALCResolvable>) resolvable
      withStack:(NSMutableArray<ALCDependencyStackItem *> *) resolvingStack
    description:(NSString *) description
          model:(id<ALCModel>) model {
    [resolvingStack addObject:[[ALCDependencyStackItem alloc] initWithObjectFactory:self description:description]];
    [resolvable resolveWithStack:resolvingStack model:model];
    [resolvingStack removeLastObject];
}

@end

NS_ASSUME_NONNULL_END

