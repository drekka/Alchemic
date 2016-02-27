//
//  ALCAbstractObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import UIKit;
@import ObjectiveC;

#import "ALCAbstractObjectFactory.h"

#import "ALCObjectFactoryType.h"
#import "ALCObjectFactoryTypeSingleton.h"
#import "ALCObjectFactoryTypeFactory.h"
#import "ALCObjectFactoryTypeReference.h"

#import "ALCInternalMacros.h"
#import "ALCModel.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractObjectFactory {
    id<ALCObjectFactoryType> _typeStrategy;
    SimpleBlock _readyBlock;
}

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

-(id) object {
    id object = _typeStrategy.object;
    if (!object) {
        object = [self instantiateObject];
        self.object = object;
    }
    return object;
}

-(void) setObject:(id) object {

    // If dependencies are not resolved then the value cannot be set.
    if (!self.resolved) {
        throwException(@"AlchemicDependenciesNotResolved", @"Cannot set object, dependencies not resolved");
    }

    _typeStrategy.object = object;
    if (_readyBlock != NULL) {
        _readyBlock();
        _readyBlock = NULL;
    }
}

-(BOOL) ready {
    return _typeStrategy.ready;
}

-(NSString *) description {

    NSMutableString *description = [[NSMutableString alloc] init];

    switch (_factoryType) {
        case ALCFactoryTypeFactory:
            [description appendString:_typeStrategy.object ? @"* " : @"  "];
            [description appendString:@"Factory "];
            break;

        case ALCFactoryTypeReference:
            [description appendString:@"  Reference "];
            break;

        default:
            [description appendString:@"  Singleton "];
    }

    [description appendString:super.description];
    return description;
}

#pragma mark - Lifecycle

-(instancetype) initWithClass:(Class) objectClass {
    self = [super initWithClass:objectClass];
    if (self) {
        [self setFactoryType:_factoryType];
    }
    return self;
}

-(id) instantiateObject {
    return nil;
}

-(void) resolveWithStack:(NSMutableArray<NSString *> *) resolvingStack
                   model:(id<ALCModel>) model {

    [super resolveWithStack:resolvingStack model:model];

    if (!self.ready) {
        blockSelf;
        _readyBlock = ^{
            [model objectFactoryReady:strongSelf];
        };
    }
}

@end

NS_ASSUME_NONNULL_END

