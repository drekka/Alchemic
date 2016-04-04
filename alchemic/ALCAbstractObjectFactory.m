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

#import "Alchemic.h"
#import "AlchemicAware.h"
#import "ALCAbstractObjectFactory.h"

#import "ALCObjectFactoryType.h"
#import "ALCObjectFactoryTypeSingleton.h"
#import "ALCObjectFactoryTypeFactory.h"
#import "ALCObjectFactoryTypeReference.h"
#import "ALCInstantiation.h"

#import "ALCInternalMacros.h"
#import "ALCModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactory {
    id<ALCObjectFactoryType> _typeStrategy;
}

@synthesize objectClass = _objectClass;
@synthesize factoryType = _factoryType;

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
        [self setFactoryType:_factoryType];
    }
    return self;
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

    BOOL instantiated = (_factoryType == ALCFactoryTypeSingleton && _typeStrategy.object)
    || (_factoryType == ALCFactoryTypeReference && _typeStrategy.ready);
    NSMutableString *description = [[NSMutableString alloc] initWithString:instantiated ? @"* " : @"  "];
    switch (_factoryType) {
        case ALCFactoryTypeFactory:
            [description appendString:@"Factory "];
            break;

        case ALCFactoryTypeReference:
            [description appendString:@"Reference "];
            break;

        default:
            [description appendString:@"Singleton "];
    }

    if ([_objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        [description appendString:@" (App delegate)"];
    }

    [description appendString:self.descriptionAttributes];
    return description;
}

-(NSString *) descriptionAttributes {
    return self.defaultName;
}

@end

NS_ASSUME_NONNULL_END

