//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCQualifier.h>
#import "ALCRuntime.h"

/**
 Block type for checking this qualifier against a builder to see if it applies.

 @param builder	the builder to be checked.

 @return YES if the builder can be matched by the qualifier.
 */
typedef BOOL(^QualifierCheck)(id<ALCBuilder> __nonnull builder);

@interface ALCQualifier ()
-(nonnull instancetype) initWithValue:(id __nonnull) value;
@end

@implementation ALCQualifier {
    QualifierCheck __nonnull _checkBlock;
}

+(nonnull instancetype) qualifierWithValue:(id __nonnull) value {
    return [[ALCQualifier alloc] initWithValue:value];
}

-(nonnull instancetype)initWithValue:(id __nonnull) value {

    self = [super init];
    if (self) {

        _value = value;

        // sort of the check block.
        if ([ALCRuntime objectIsAClass:value]) {
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [ALCRuntime aClass:builder.valueClass isKindOfClass:value];
            };
        } else if ([ALCRuntime objectIsAProtocol:value]) {
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [ALCRuntime aClass:builder.valueClass conformsToProtocol:value];
            };
        } else {
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [value isEqualToString:builder.name];
            };
        }
    }
    return self;
}

-(BOOL) matchesBuilder:(id<ALCBuilder> __nonnull) builder {
    return _checkBlock(builder);
}

-(NSString *) description {
    return [@"Arg: %s" stringByAppendingString:[_value description]];
}

@end
