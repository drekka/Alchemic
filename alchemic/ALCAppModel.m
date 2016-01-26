//
//  ALCAppModel.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAppModel.h"
#import "ALCObjectFactory.h"
#import "ALCAbstractObjectFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAppModel {
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

-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory {
    if (_objectFactories[objectFactory.name]) {
        @throw [NSException exceptionWithName:@"AlchemicDuplicateName"
                                       reason:[NSString stringWithFormat:@"Object factory names must be unique. Duplicate name: %@ used for %@ and %@", objectFactory.name, objectFactory, _objectFactories[objectFactory.name]]
                                     userInfo:nil];
    }
    _objectFactories[objectFactory.name] = objectFactory;
}

-(NSArray<id<ALCObjectFactory>> *) objectFactoriesPassingTest:(ALCObjectFactoryTest) test {
    NSSet<NSString *> *keys = [_objectFactories keysOfEntriesPassingTest:^BOOL(NSString *name, id<ALCObjectFactory> objectFactory, BOOL *stop) {
        return test(objectFactory);
    }];
    NSArray<NSString *> *keyArray = keys.allObjects;
    return [_objectFactories objectsForKeys:keyArray notFoundMarker:[ALCAbstractObjectFactory NoFactoryInstance]];
}

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory changedName:(NSString *) oldName newName:(NSString *) newName {
    [_objectFactories removeObjectForKey:oldName];
    objectFactory.name = newName;
    [self addObjectFactory:objectFactory];
}

@end

NS_ASSUME_NONNULL_END