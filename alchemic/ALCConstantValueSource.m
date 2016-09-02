//
//  ALCAbstractConstantValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 30/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCConstantValueSource.h>
#import <Alchemic/ALCType.h>
#import <Alchemic/ALCValue.h>
#import <Alchemic/ALCInternalMacros.h>

@implementation ALCConstantValueSource {
    id _value;
}

+(instancetype) valueSourceWithObject:(id) object {
    ALCType *type = [ALCType typeWithClass:[object class]];
    ALCConstantValueSource *source = [[ALCConstantValueSource alloc] initWithType:type value:object];
    return source;
}

+(instancetype) valueSourceWithInt:(int) value {
    return [self scalarValueSourceWithValue:[NSValue valueWithBytes:&value objCType:@encode(__typeof(value))]];
}

+(instancetype) valueSourceWithScalar:(void *) value {
    return [self scalarValueSourceWithValue:[NSValue valueWithBytes:value objCType:@encode(__typeof(* value))]];
}

#pragma mark - Internal factory methods

+(instancetype) scalarValueSourceWithValue:(NSValue *) value {
    ALCType *type = [ALCType typeWithEncoding:value.objCType];
    return [[ALCConstantValueSource alloc] initWithType:type value:value];
}


#pragma mark - Value source methods

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
    return [self.type withValue:_value completion:NULL];
}

-(NSString *)resolvingDescription {
    return self.type.description;
}

@end
