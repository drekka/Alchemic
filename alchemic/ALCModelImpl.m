//
//  ALCAppModel.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import StoryTeller;

// :: Framework ::
#import <Alchemic/ALCAbstractObjectFactory.h>
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCModelImpl.h>
#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCObjectFactory.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelImpl {
    NSMutableDictionary<NSString *, id<ALCObjectFactory>> *_objectFactories;
    ALCClassObjectFactory *_uiAppDelegateFactory;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _objectFactories = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Accessing factories

-(NSArray<id<ALCObjectFactory>> *) objectFactories {
    return _objectFactories.allValues;
}

-(NSArray<ALCClassObjectFactory *> *) classObjectFactories {
    return [self.objectFactories filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id<ALCObjectFactory> objectFactory, NSDictionary<NSString *, id> *bindings) {
        return [objectFactory isKindOfClass:[ALCClassObjectFactory class]];
    }]];
}

-(nullable ALCClassObjectFactory *) classObjectFactoryForClass:(Class) aClass {
    for (id<ALCObjectFactory> objectFactory in _objectFactories) {
        if ([objectFactory isKindOfClass:[ALCClassObjectFactory class]]
            && objectFactory.objectClass == aClass) {
            return objectFactory;
        }
    }
    return nil;
}

-(NSDictionary<NSString *, id<ALCObjectFactory>> *) objectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria {
    NSMutableDictionary<NSString *, id<ALCObjectFactory>> *results = [[NSMutableDictionary alloc] init];
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        if ([criteria acceptsObjectFactory:objectFactory name:name]) {
            results[name] = objectFactory;
        }
    }];
    return results;
}

-(NSArray<id<ALCObjectFactory>> *) settableObjectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria {
    NSDictionary<NSString *, id<ALCObjectFactory>> *factories = [self objectFactoriesMatchingCriteria:criteria];
    NSMutableArray<id<ALCObjectFactory>> *results = [[NSMutableArray alloc] init];
    [factories enumerateKeysAndObjectsUsingBlock:^(NSString *name, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        if (objectFactory.factoryType == ALCFactoryTypeSingleton || objectFactory.factoryType == ALCFactoryTypeReference) {
            [results addObject:objectFactory];
        }
    }];
    return results;
}

#pragma mark - The model

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory withName:(NSString *) name {
    if (_objectFactories[name]) {
        throwException(DuplicateName, @"Object factory names must be unique. Duplicate name: %@ used for %@ and %@", name, objectFactory, _objectFactories[name]);
    }
    _objectFactories[name] = objectFactory;
}

-(void) reindexObjectFactoryOldName:(NSString *) oldName newName:(NSString *) newName {
    id<ALCObjectFactory> factory = _objectFactories[oldName];
    _objectFactories[oldName] = nil;
    [self addObjectFactory:factory withName:newName];
    [_objectFactories removeObjectForKey:oldName];
}

#pragma mark - Life cycle

-(void) resolveDependencies {
    
    [self modelWillResolve];
    
    STLog(self, @"Resolving ...");
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        [objectFactory resolveWithStack:[NSMutableArray array] model:self];
    }];
}

-(void) modelWillResolve {
    
    // Locate special factories and configure them.
    [self.classObjectFactories enumerateObjectsUsingBlock:^(ALCClassObjectFactory *objectFactory, NSUInteger idx, BOOL *stop) {
        
        // UIApplicationDelegate
        if ([objectFactory.objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
            self->_uiAppDelegateFactory = objectFactory;
            [objectFactory configureWithOptions:@[[ALCIsReference macro]] model:self];
            *stop = YES;
        }
    }];
}

-(void) startSingletons {
    
    STLog(self, @"Instantiating ...");
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        if (objectFactory.factoryType == ALCFactoryTypeSingleton
            && objectFactory.isReady) {
            STLog(objectFactory.objectClass, @"Starting %@, as '%@'", [objectFactory description], key);
            ALCInstantiation *instantiation = objectFactory.instantiation;
            __unused id obj = instantiation.object;
            [instantiation complete];
        }
    }];
    
    [self modelDidInstantiate];
}

-(void) modelDidInstantiate {
    if (_uiAppDelegateFactory) {
        id delegate = [UIApplication sharedApplication].delegate;
        if (delegate) {
            STLog(self, @"Injecting UIApplicationDelegate instance into model");
            ALCObjectCompletion completion = [_uiAppDelegateFactory setObject:delegate];
            completion(delegate);
        }
    }
}

#pragma mark - Logging

-(NSString *) description {
    NSMutableString *desc = [NSMutableString stringWithString:@"Finished model (* - instantiated):"];
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        [desc appendFormat:@"\n\t%@, as '%@'", [objectFactory description], key];
    }];
    return desc;
}

@end

NS_ASSUME_NONNULL_END
