//
//  ALCAbstractConstantValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCConstantValueSource.h"
#import <Alchemic/ALCValue.h>
#import <Alchemic/ALCInternalMacros.h>

@implementation ALCConstantValueSource {
    NSValue *_value;
    id _retainedValue; // Used when [NSValue valueWithNonretainedObject:] is used.
}

+(instancetype) valueSourceWithNil {
    ALCType *type = [ALCType typeWithClass:[NSObject class]];
    NSValue *value = [NSValue valueWithNonretainedObject:nil];
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:type value:value];
    return source;
}

+(instancetype) valueSourceWithObject:(id) object {
    ALCType *type = [ALCType typeWithClass:[object class]];
    NSValue *value = [NSValue valueWithNonretainedObject:object];
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:type value:value];
    source->_retainedValue = object;
    return source;
}

+(instancetype) valueSourceWithInt:(int) value {
    ALCType *type = [ALCType typeWithEncoding:"i"];
    int localValue = value;
    NSValue *wrappedValue = [NSValue valueWithBytes:&localValue objCType:"i"];
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:type value:wrappedValue];
    return source;
}

-(instancetype) initWithType:(ALCType *) type {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithType:(ALCType *) type value:(NSValue *) value {
    self = [super initWithType:type];
    if (self) {
        _value = value;
    }
    return self;
}


-(nullable ALCValue *) valueWithError:(NSError * __autoreleasing _Nullable *) error {
    return [ALCValue valueWithType:self.type value:_value completion:NULL];
}

-(NSString *)resolvingDescription {
    return self.type.typeDescription;
}

@end
