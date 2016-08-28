//
//  ALCAbstractDependencyDecorator.m
//  alchemic
//
//  Created by Derek Clarkson on 16/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import "ALCAbstractDependency.h"

#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCValueSource.h>

@implementation ALCAbstractDependency

@synthesize type = _type;
@synthesize valueSource = _valueSource;

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithType:(ALCType *) type
                 valueSource:(id<ALCValueSource>) valueSource {
    self = [super init];
    if (self) {
        _type = type;
        _valueSource = valueSource;
    }
    return self;
}

+(instancetype) argumentWithType:(ALCType *) type
                     valueSource:(id<ALCValueSource>) valueSource {
    return [[self alloc] initWithType:type valueSource:valueSource];
}

#pragma mark - ALCResolvable

-(BOOL) isReady {
    return YES;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack
                   model:(id<ALCModel>)model {
    STLog(self, @"Resolving %@", self.resolvingDescription);
    [_valueSource resolveWithStack:resolvingStack model:model];
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    return [_valueSource referencesObjectFactory:objectFactory];
}

-(NSString *) resolvingDescription {
    methodReturningStringNotImplemented;
}

#pragma mark - ALCDependency

-(NSString *)stackName {
    methodReturningStringNotImplemented;
}

-(void) injectObject:(id)object {
    methodNotImplemented;
}

@end
