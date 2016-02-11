//
//  ALCAppModel.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCModelImpl.h"
#import "ALCObjectFactory.h"
#import "ALCObjectFactoryImpl.h"
#import "ALCModelSearchCriteria.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelImpl {
    NSMutableDictionary<NSString *, id<ALCObjectFactory>> *_objectFactories;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _objectFactories = [@{} mutableCopy];
    }
    return self;
}

-(NSArray<id<ALCObjectFactory>> *) objectFactories {
    return _objectFactories.allValues;
}

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory withName:(NSString *) name {
    if (_objectFactories[name]) {
        @throw [NSException exceptionWithName:@"AlchemicDuplicateName"
                                       reason:str(@"Object factory names must be unique. Duplicate name: %@ used for %@ and %@", name, objectFactory, _objectFactories[name])
                                     userInfo:nil];
    }
    _objectFactories[name] = objectFactory;
}

-(void) resolveDependencies {
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        STLog(self, @"Resolving '%@'...", key);
        if (!objectFactory.resolved) {
            [objectFactory resolveWithStack:[NSMutableArray array] model:self];
        }
    }];
}

-(void) startSingletons {
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        if (objectFactory.resolved) {
            STLog(self, @"Starting '%@'...", key);
            [objectFactory object];
        }
    }];
}

-(NSArray<id<ALCObjectFactory>> *) objectFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria {
    NSSet<NSString *> *keys = [_objectFactories keysOfEntriesPassingTest:^BOOL(NSString *name, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        return [criteria acceptsObjectFactory:objectFactory name:name];
    }];
    NSArray<NSString *> *keyArray = keys.allObjects;
    return [_objectFactories objectsForKeys:keyArray notFoundMarker:[ALCObjectFactoryImpl NoFactoryInstance]];
}

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory changedName:(NSString *) oldName newName:(NSString *) newName {
    [_objectFactories removeObjectForKey:oldName];
    [self addObjectFactory:objectFactory withName:newName];
}

-(NSString *) description {
    NSMutableString *desc = [NSMutableString stringWithString:@"Model:"];
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        [desc appendFormat:@"\n\t%@, name:'%@'", [objectFactory description], key];
    }];
    return desc;
}

@end

NS_ASSUME_NONNULL_END
