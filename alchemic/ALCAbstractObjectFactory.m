//
//  ALCAbstractObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
@import UIKit;
#import <Alchemic/ALCAbstractObjectFactory.h>
// :: Framework ::
@import StoryTeller;
// :: Other ::
#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCDefs.h>
#import <Alchemic/ALCFactoryName.h>
#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCObjectFactoryType.h>
#import <Alchemic/ALCObjectFactoryTypeTemplate.h>
#import <Alchemic/ALCObjectFactoryTypeReference.h>
#import <Alchemic/ALCObjectFactoryTypeSingleton.h>
#import <Alchemic/ALCRuntime.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactory {
    id<ALCObjectFactoryType> _typeStrategy;
    // The notification observer listening to dependency updates. Currently only used by transient dependencies.
    id _dependencyChangedObserver;
}

@synthesize objectClass = _objectClass;
@synthesize primary = _primary;
@dynamic weak;
@dynamic ready;

#pragma mark - Property overrides

-(ALCFactoryType) factoryType {
    return _typeStrategy.type;
}

-(BOOL) isWeak {
    return _typeStrategy.isWeak;
}

-(BOOL) isReady {
    return _typeStrategy.isReady;
}

-(NSString *) defaultModelKey {
    return NSStringFromClass(self.objectClass);
}

#pragma mark - Lifecycle

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        _typeStrategy = [[ALCObjectFactoryTypeSingleton alloc] init];
    }
    return self;
}

-(void) configureWithOptions:(NSArray *) options model:(id<ALCModel>) model {
    for (id option in options) {
        [self configureWithOption:option model:model];
    }
}

-(void) configureWithOption:(id) option model:(id<ALCModel>) model {
    
    id<ALCObjectFactoryType> oldStrategy = _typeStrategy;
    
    if ([option isKindOfClass:[ALCIsTemplate class]]) {
        _typeStrategy = [[ALCObjectFactoryTypeTemplate alloc] init];
        _typeStrategy.weak = oldStrategy.isWeak;
        _typeStrategy.nullable = oldStrategy.isNullable;
        
    } else if ([option isKindOfClass:[ALCIsReference class]]) {
        _typeStrategy = [[ALCObjectFactoryTypeReference alloc] init];
        _typeStrategy.weak = oldStrategy.isWeak;
        _typeStrategy.nullable = oldStrategy.isNullable;
        
    } else if ([option isKindOfClass:[ALCIsPrimary class]]) {
        _primary = YES;
        
    } else if ([option isKindOfClass:[ALCFactoryName class]]) {
        NSString *newName = ((ALCFactoryName *) option).asName;
        [model reindexObjectFactoryOldName:self.defaultModelKey newName:newName];
        
    } else if ([option isKindOfClass:[ALCIsWeak class]]) {
        _typeStrategy.weak = YES;
        
    } else if ([option isKindOfClass:[ALCIsNullable class]]) {
        _typeStrategy.nullable = YES;
        
    } else {
        throwException(IllegalArgument, @"Expected a factory config macro");
    }
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {}

-(void) setDependencyUpdateObserverWithBlock:(void (^) (NSNotification *)) watchBlock {
    STLog(self.objectClass, @"Watch for dependency changes");
    self->_dependencyChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AlchemicDidStoreObject
                                                                                         object:nil
                                                                                          queue:nil
                                                                                     usingBlock:watchBlock];
}

-(ALCInstantiation *) instantiation {
    id object = _typeStrategy.object;
    if (object || _typeStrategy.nullable) {
        return [ALCInstantiation instantiationWithObject:object completion:NULL];
    }
    object = [self createObject];
    ALCBlockWithObject completion = [self storeObject:object];
    return [ALCInstantiation instantiationWithObject:object completion:completion];
}

-(id) createObject {
    methodNotImplemented;
    return [NSNull null];
}

-(ALCBlockWithObject) objectCompletion {
    methodReturningBlockNotImplemented;
}

#pragma mark - Updating

-(void) setObject:(nullable id) object {
    
    id oldValue = _typeStrategy.isReady ? _typeStrategy.object : nil; // Allows for references types which will throw if not ready.

    // forward to the storeObject: method.
    ALCBlockWithObject completion = [self storeObject:object];
    [ALCRuntime executeBlock:completion withObject:object];

    // Let other factories know we have updated.
    [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidStoreObject
                                                        object:self
                                                      userInfo:@{
                                                                 AlchemicDidStoreObjectUserInfoOldValue:oldValue ? oldValue : [NSNull null],
                                                                 AlchemicDidStoreObjectUserInfoNewValue:object ? object : [NSNull null]
                                                                 }];
}

-(ALCBlockWithObject) storeObject:(nullable id) object {
    _typeStrategy.object = object;
    return object ? self.objectCompletion : NULL;
}

-(void) unload {
    if (_dependencyChangedObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_dependencyChangedObserver];
    }
}

#pragma mark - Descriptions

-(NSString *)resolvingDescription {
    methodNotImplemented;
    return @"";
}

-(NSString *) description {
    
    NSMutableString *description = [[NSMutableString alloc] initWithString:_typeStrategy.isObjectPresent ? @"* " : @"  "];
    
    [description appendString:_typeStrategy.description];
    
    if ([_objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        [description appendString:@" (App delegate)"];
    }
    
    return description;
}

@end

NS_ASSUME_NONNULL_END

