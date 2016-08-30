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
    NSString *_desc;
    NSValue *_value;
}

+(instancetype) valueSourceWithNil {
    return [[ALCConstantValueSource alloc] initWithType:[ALCType typeWithClass:[NSObject class]] typeDescription:@"object" value:[NSValue valueWithNonretainedObject:nil]];
}

-(instancetype) initWithType:(ALCType *) type {
    methodReturningObjectNotImplemented;
}

-(instancetype) initWithType:(ALCType *) type typeDescription:(NSString *) desc value:(NSValue *) value {
    self = [super initWithType:type];
    if (self) {
        _value = value;
        _desc = desc;
    }
    return self;
}


-(nullable ALCValue *) valueWithError:(NSError * __autoreleasing _Nullable *) error {
    return [ALCValue valueWithType:self.type value:_value completion:NULL];
}

-(NSString *)resolvingDescription {
    return _desc;
}

@end
