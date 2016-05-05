//
//  ALCAbstractObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCAbstractObjectFactory.h"

#import "AlchemicAware.h"

#import "ALCObjectFactoryType.h"
#import "ALCObjectFactoryTypeSingleton.h"
#import "ALCObjectFactoryTypeFactory.h"
#import "ALCObjectFactoryTypeReference.h"
#import "ALCInstantiation.h"

#import "ALCInternalMacros.h"
#import "ALCModel.h"

#import "ALCIsFactory.h"
#import "ALCIsReference.h"
#import "ALCIsPrimary.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactory {
    id<ALCObjectFactoryType> _typeStrategy;
}

@synthesize objectClass = _objectClass;

#pragma mark - Property overrides

-(ALCFactoryType) factoryType {
    return _typeStrategy.factoryType;
}

-(BOOL) ready {
    return _typeStrategy.ready;
}

-(NSString *) defaultName {
    return NSStringFromClass(self.objectClass);
}

#pragma mark - Lifecycle

-(instancetype) init {
    return nil;
}

-(instancetype) initWithClass:(Class) objectClass {
    self = [super init];
    if (self) {
        _objectClass = objectClass;
        _typeStrategy = [[ALCObjectFactoryTypeSingleton alloc] init];
    }
    return self;
}

-(void) configureWithOptions:(NSArray *) options unknownOptionHandler:(void (^)(id option)) unknownOptionHandler {
    for (id option in options) {
        if ([option isKindOfClass:[ALCIsFactory class]]) {
            _typeStrategy = [[ALCObjectFactoryTypeFactory alloc] init];
        } else if ([option isKindOfClass:[ALCIsReference class]]) {
            _typeStrategy = [[ALCObjectFactoryTypeReference alloc] init];
        } else {
            unknownOptionHandler(option);
        }
    }
}

-(void) resolveWithStack:(NSMutableArray<NSString *> *)resolvingStack model:(id<ALCModel>) model {}

-(ALCInstantiation *) objectInstantiation {

    id object = _typeStrategy.object;
    if (object) {
        return [ALCInstantiation instantiationWithObject:object completion:NULL];
    }

    ALCInstantiation *result = [self createObject];
    [self setObject:result.object];
    return result;
}

-(ALCInstantiation *) createObject {
    methodReturningObjectNotImplemented;
}

-(void) objectFinished:(id) object {
    if ([object conformsToProtocol:@protocol(AlchemicAware)]) {
        [(id<AlchemicAware>)object alchemicDidInjectDependencies];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:AlchemicDidCreateObject
                                                        object:self
                                                      userInfo:@{AlchemicDidCreateObjectUserInfoObject: object}];
}

#pragma mark - Updating

-(void) setObject:(id) object {
    _typeStrategy.object = object;
}

#pragma mark - Descriptions

-(NSString *) description {

    ALCFactoryType factoryType = _typeStrategy.factoryType;
    BOOL instantiated = (factoryType == ALCFactoryTypeSingleton && _typeStrategy.object)
    || (factoryType == ALCFactoryTypeReference && _typeStrategy.ready);
    NSMutableString *description = [[NSMutableString alloc] initWithString:instantiated ? @"* " : @"  "];

    [description appendString:_typeStrategy.description];

    if ([_objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        [description appendString:@" (App delegate)"];
    }

    [description appendString:self.descriptionAttributes];
    return description;
}

-(NSString *) descriptionAttributes {
    return str(@" %@", self.defaultName);
}

@end

NS_ASSUME_NONNULL_END

