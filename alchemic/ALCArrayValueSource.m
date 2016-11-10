//
//  ALCArrayValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCValueSource.h"
#import "ALCObjectFactory.h"
#import "ALCArrayValueSource.h"
#import "ALCInternalMacros.h"
#import "ALCResolvable.h"
#import "ALCType.h"
#import "ALCValue.h"
#import "ALCTypeDefs.h"

@implementation ALCArrayValueSource {
    NSArray<id<ALCValueSource>> *_sources;
}

+(instancetype) valueSourceWithValueSources:(NSArray<id<ALCValueSource>> *) sources {
    return [[self alloc] initWithValueSources:sources];
}

-(instancetype) initWithType:(ALCType *) type {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithValueSources:(NSArray<id<ALCValueSource>> *) sources {
    self = [super initWithType:[ALCType typeWithClass:[NSArray class]]];
    if (self) {
        _sources = sources;
    }
    return self;
}

-(void) resolveWithStack:(NSMutableArray<id<ALCResolvable>> *) resolvingStack model:(id<ALCModel>)model {
    for (id<ALCValueSource> source in _sources) {
        [resolvingStack addObject:self];
        [source resolveWithStack:resolvingStack model:model];
        [resolvingStack removeLastObject];
    }
}

-(nullable ALCValue *) value {

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:_sources.count];
    NSMutableArray<ALCValue *> *values = [NSMutableArray arrayWithCapacity:_sources.count];

    for (id<ALCValueSource> source in _sources) {
        ALCValue *value = source.value;
        [results addObject:value.object];
        [values addObject:value];
    }

    return [ALCValue withObject:results
                    completion:^(__unused id obj){
                        for (ALCValue *value in values) {
                            [value complete];
                        }
                    }];
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    for (id<ALCValueSource> source in _sources) {
        if ([source referencesObjectFactory:objectFactory]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL) isReady {
    for (id<ALCValueSource> source in _sources) {
        if (!source.isReady) {
            return NO;
        }
    }
    return YES;
}

-(NSString *) resolvingDescription {
    return @"array of value sources";
}

@end
