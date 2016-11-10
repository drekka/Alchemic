//
//  ALCAppModel.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import StoryTeller;

#import "ALCModelImpl.h"

#import "ALCMacros.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelImpl {
    NSMutableDictionary<NSString *, id<ALCObjectFactory>> *_objectFactories;
    ALCClassObjectFactory *_uiAppDelegateFactory;
    NSMutableSet<id<ALCResolveAspect>> *_resolveAspects;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _objectFactories = [[NSMutableDictionary alloc] init];
        _resolveAspects = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark - Accessing factories

-(NSArray<id<ALCObjectFactory>> *) objectFactories {
    return _objectFactories.allValues;
}

-(NSArray<ALCClassObjectFactory *> *) classObjectFactories {
    return [self.objectFactories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ALCObjectFactory> factory, NSDictionary<NSString *, id> *bindings) {
        return [factory isKindOfClass:[ALCClassObjectFactory class]];
    }]];
}

-(nullable ALCClassObjectFactory *) classObjectFactoryMatchingCriteria:(ALCModelSearchCriteria *) criteria {
    NSArray<id<ALCObjectFactory>> *factories = [self objectFactoriesMatchingCriteria:criteria];
    factories = [factories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ALCObjectFactory> factory, NSDictionary<NSString *,id> *bindings) {
        return [factory isKindOfClass:[ALCClassObjectFactory class]];
    }]];
    if (factories.count > 1) {
        throwException(AlchemicTooManyResultsException, @"Expected 1 object factory for critieria '%@', but found %lu.", criteria, (unsigned long) factories.count);
    } else if (factories.count == 0) {
        return nil;
    } else {
        return factories[0];
    }
}

-(NSArray<id<ALCObjectFactory>> *) objectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria {
    NSMutableDictionary<NSString *, id<ALCObjectFactory>> *results = [[NSMutableDictionary alloc] init];
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        if ([criteria acceptsObjectFactory:objectFactory name:name]) {
            results[name] = objectFactory;
        }
    }];
    return results.allValues;
}

-(NSArray<id<ALCObjectFactory>> *) settableObjectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria {
    NSArray<id<ALCObjectFactory>> *factories = [self objectFactoriesMatchingCriteria:criteria];
    return [factories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ALCObjectFactory> factory, NSDictionary<NSString *,id> *bindings) {
        return factory.factoryType == ALCFactoryTypeSingleton || factory.factoryType == ALCFactoryTypeReference;
    }]];
}

#pragma mark - The model

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory withName:(nullable NSString *) name {
    NSString *finalName = name ? name : objectFactory.defaultModelName;
    if (_objectFactories[finalName]) {
        throwException(AlchemicDuplicateNameException, @"Object factory names must be unique. Duplicate name: %@ used for %@ and %@", name, objectFactory, _objectFactories[finalName]);
    }
    _objectFactories[finalName] = objectFactory;
}

-(void) reindexObjectFactoryOldName:(NSString *) oldName newName:(NSString *) newName {
    id<ALCObjectFactory> factory = _objectFactories[oldName];
    _objectFactories[oldName] = nil;
    [self addObjectFactory:factory withName:newName];
    [_objectFactories removeObjectForKey:oldName];
}

#pragma mark - Life cycle

-(void) addResolveAspect:(id<ALCResolveAspect>) resolveAspect {
    [_resolveAspects addObject:resolveAspect];
}

-(void) resolveDependencies {
    
    STLog(self, @"Resolving model ...");
    [self modelWillResolve];
    
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        STLog(self, @"--- Initiating resolve for %@ factory ----", key);
        [objectFactory resolveWithStack:[NSMutableArray array] model:self];
    }];

    [self modelDidResolve];
}

-(void) modelWillResolve {
    STLog(self, @"Model will resolve");
    for (NSObject<ALCResolveAspect> *aspect in _resolveAspects) {
        STLog(self, @"Checking %@", aspect);
        if ([[aspect class] enabled] && [aspect respondsToSelector:@selector(modelWillResolve:)]) {
            STLog(self, @"Calling aspect will resolve");
            [aspect modelWillResolve:self];
        }
    }
}

-(void) modelDidResolve {
    for (NSObject<ALCResolveAspect> *aspect in _resolveAspects) {
        if ([[aspect class] enabled] && [aspect respondsToSelector:@selector(modelDidResolve:)]) {
            STLog(self, @"Calling aspect did resolve");
            [aspect modelDidResolve:self];
        }
    }
}

-(void) startSingletons {
    STLog(self, @"Instantiating singletons ...");
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        if (objectFactory.factoryType == ALCFactoryTypeSingleton
            && objectFactory.isReady) {
            STLog(self, @"Starting %@, as '%@'", [objectFactory description], key);
            ALCValue *value = objectFactory.value;
            __unused id obj = value.object;
            [value complete];
        }
    }];
}

#pragma mark - Logging

-(NSString *) description {
    NSMutableString *desc = [NSMutableString stringWithString:@"\n\nAlchemic model (* - instantiated):"];
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        [desc appendFormat:@"\n\t%@, as '%@'", [objectFactory description], key];
    }];
    [desc appendString:@"\n"];
    return desc;
}

@end

NS_ASSUME_NONNULL_END
