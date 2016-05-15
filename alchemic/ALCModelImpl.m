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
#import "ALCAbstractObjectFactory.h"
#import "ALCModelSearchCriteria.h"
#import "ALCInternalMacros.h"
#import "ALCInstantiation.h"

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
        throwException(@"AlchemicDuplicateName", nil, @"Object factory names must be unique. Duplicate name: %@ used for %@ and %@", name, objectFactory, _objectFactories[name]);
    }
    _objectFactories[name] = objectFactory;
}

-(void) resolveDependencies {
    STLog(self, @"Resolving ...");
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        [objectFactory resolveWithStack:[NSMutableArray array] model:self];
    }];
}

-(void) startSingletons {
    STLog(self, @"Instantiating ...");
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        if (objectFactory.factoryType == ALCFactoryTypeSingleton
            && objectFactory.ready) {
            STLog(objectFactory.objectClass, @"Starting '%@'", key);
            ALCInstantiation *instantiation = objectFactory.instantiation;
            __unused id obj = instantiation.object;
            [instantiation complete];
        }
    }];
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

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory changedName:(NSString *) oldName newName:(NSString *) newName {
    [_objectFactories removeObjectForKey:oldName];
    [self addObjectFactory:objectFactory withName:newName];
}

-(NSString *) description {
    NSMutableString *desc = [NSMutableString stringWithString:@"Finished model (* - instantiated):"];
    [_objectFactories enumerateKeysAndObjectsUsingBlock:^(NSString *key, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        [desc appendFormat:@"\n\t%@, as '%@'", [objectFactory description], key];
    }];
    return desc;
}

@end

NS_ASSUME_NONNULL_END
