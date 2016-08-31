//
//  ALCArrayValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCArrayValueSource.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCValue.h>
#import <Alchemic/ALCTypeDefs.h>

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

-(nullable ALCValue *) valueWithError:(NSError * __autoreleasing _Nullable *) error {

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:_sources.count];
    NSMutableArray *completions = [NSMutableArray arrayWithCapacity:_sources.count];

    // Retrieve all values and completion blocks.
    for (id<ALCValueSource> source in _sources) {
        ALCValue *value = [source valueWithError:error];
        if (!value) {
            return nil;
        }
        [results addObject:value];
        ALCSimpleBlock completion = value.completion;
        if (completion) {
            [completions addObject:completion];
        }
    }

    // Combine the blocks.
    ALCSimpleBlock allCompletions = ^{
        for (ALCSimpleBlock block in completions) {
            block();
        }
    };

    return [[ALCType typeWithClass:[NSArray class]] withValue:results
                                                   completion:allCompletions];
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
