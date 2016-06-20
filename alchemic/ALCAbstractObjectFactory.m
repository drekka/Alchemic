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
#import <Alchemic/ALCFactoryName.h>
#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCObjectFactoryType.h>
#import <Alchemic/ALCObjectFactoryTypeFactory.h>
#import <Alchemic/ALCObjectFactoryTypeReference.h>
#import <Alchemic/ALCObjectFactoryTypeSingleton.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactory {
    id<ALCObjectFactoryType> _typeStrategy;
}

@synthesize objectClass = _objectClass;
@synthesize primary = _primary;

#pragma mark - Property overrides

-(ALCFactoryType) factoryType {
    return _typeStrategy.factoryType;
}

-(BOOL) ready {
    return _typeStrategy.ready;
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

    if ([option isKindOfClass:[ALCIsTemplate class]]) {
        _typeStrategy = [[ALCObjectFactoryTypeFactory alloc] init];

    } else if ([option isKindOfClass:[ALCIsReference class]]) {
        _typeStrategy = [[ALCObjectFactoryTypeReference alloc] init];

    } else if ([option isKindOfClass:[ALCIsPrimary class]]) {
        _primary = YES;

    } else if ([option isKindOfClass:[ALCFactoryName class]]) {
        NSString *newName = ((ALCFactoryName *) option).asName;
        [model reindexObjectFactoryOldName:self.defaultModelKey newName:newName];

    } else {
        throwException(IllegalArgument, @"Expected a factory config macro");
    }
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model {}

-(ALCInstantiation *) instantiation {
    id object = _typeStrategy.object;
    if (object) {
        return [ALCInstantiation instantiationWithObject:object completion:NULL];
    }
    object = [self createObject];
    ALCObjectCompletion completion = [self setObject:object];
    return [ALCInstantiation instantiationWithObject:object completion:completion];
}

-(id) createObject {
    methodNotImplemented;
    return [NSNull null];
}

-(ALCObjectCompletion) objectCompletion {
    methodReturningBlockNotImplemented;
}

#pragma mark - Updating

-(ALCObjectCompletion) setObject:(id) object {
    _typeStrategy.object = object;
    return self.objectCompletion;
}

#pragma mark - Descriptions

-(NSString *)resolvingDescription {
    methodNotImplemented;
    return @"";
}

-(NSString *) description {

    ALCFactoryType factoryType = _typeStrategy.factoryType;
    BOOL instantiated = (factoryType == ALCFactoryTypeSingleton && _typeStrategy.object)
    || (factoryType == ALCFactoryTypeReference && _typeStrategy.ready);
    NSMutableString *description = [[NSMutableString alloc] initWithString:instantiated ? @"* " : @"  "];

    [description appendString:_typeStrategy.description];

    if ([_objectClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        [description appendString:@" (App delegate)"];
    }

    return description;
}

@end

NS_ASSUME_NONNULL_END

