//
//  ALCAppModel.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCModelImpl.h"
#import "ALCValueFactory.h"
#import "ALCValueFactoryImpl.h"
#import "ALCModelSearchCriteria.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCModelImpl {
    NSMutableDictionary<NSString *, id<ALCValueFactory>> *_valueFactories;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _valueFactories = [@{} mutableCopy];
    }
    return self;
}

-(NSArray<id<ALCValueFactory>> *) valueFactories {
    return _valueFactories.allValues;
}

-(void) addValueFactory:(id<ALCValueFactory>) valueFactory withName:(NSString *) name {
    if (_valueFactories[name]) {
        @throw [NSException exceptionWithName:@"AlchemicDuplicateName"
                                       reason:[NSString stringWithFormat:@"Value factory names must be unique. Duplicate name: %@ used for %@ and %@", name, valueFactory, _valueFactories[name]]
                                     userInfo:nil];
    }
    _valueFactories[name] = valueFactory;
}

-(NSArray<id<ALCValueFactory>> *) valueFactoriesMatchingCriteria:(ALCModelSearchCriteria *) criteria {
    NSSet<NSString *> *keys = [_valueFactories keysOfEntriesPassingTest:^BOOL(NSString *name, id<ALCValueFactory> valueFactory, BOOL *stop) {
        return [criteria acceptsValueFactory:valueFactory name:name];
    }];
    NSArray<NSString *> *keyArray = keys.allObjects;
    return [_valueFactories objectsForKeys:keyArray notFoundMarker:[ALCValueFactoryImpl NoFactoryInstance]];
}

-(void) valueFactory:(id<ALCValueFactory>) valueFactory changedName:(NSString *) oldName newName:(NSString *) newName {
    [_valueFactories removeObjectForKey:oldName];
    [self addValueFactory:valueFactory withName:newName];
}

@end

NS_ASSUME_NONNULL_END
