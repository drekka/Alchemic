//
//  ALCArrayValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCArrayValueSource.h"
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCValue.h>

@implementation ALCArrayValueSource {
    NSArray<id<ALCValueSource>> *_sources;
}

-(instancetype) init {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithValueSources:(NSArray<id<ALCValueSource>> *) sources {
    self = [super init];
    if (self) {
        _sources = sources;
    }
    return self;
}

-(ALCValue *) valueWithError:(NSError * _Nullable *) error {

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:_sources.count];
    for (id<ALCValueSource> source in _sources) {
        id value = [source valueWithError:error];
        // Allow for the value being nil.
        if (!value && error) {
            return nil;
        }
        [results addObject:value ? value : [NSNull null] ];
    }
    return [ALCValue valueWithType:[ALCType typeWithClass:[NSArray class]] value:results];
}

-(BOOL) referencesObjectFactory:(id<ALCObjectFactory>) objectFactory {
    
}

@end
