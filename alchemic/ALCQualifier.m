//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>
#import <Alchemic/ALCInternalMacros.h>
#import "ALCRuntime.h"
#import <StoryTeller/StoryTeller.h>
#import "ALCQualifier+Internal.h"

// We need to re-apply the protocol here, otherwise Objective-C does not see it. I think it's because
// It's applied on a category and Objective-C regards the protocol methods as being part of the category.
@interface ALCQualifier()<ALCModelSearchExpression>
@end

@implementation ALCQualifier {
    NSString *_descTemplate;
}

@synthesize type = _type;
@synthesize matchBlock = _matchBlock;

+(nonnull instancetype) qualifierWithValue:(id __nonnull) value {
    return [[ALCQualifier alloc] initWithValue:value];
}

-(nonnull instancetype)initWithValue:(id __nonnull) value {

    self = [super init];
    if (self) {

        _value = value;

        // sort of the check block.
        if ([ALCRuntime objectIsAClass:value]) {
            _type = ALCModelSearchExpressionTypeClass;
            _descTemplate = [NSString stringWithFormat:@"Qualifier [%s]", class_getName(value)];
            STLog(value, _descTemplate);
            _matchBlock = ^BOOL(ALCMatchBuilderBlockArgs) {
                return [builder.valueClass isSubclassOfClass:value];
            };

        } else if ([ALCRuntime objectIsAProtocol:value]) {
            _type = ALCModelSearchExpressionTypeProtocol;
            _descTemplate = [NSString stringWithFormat:@"Qualifier <%s>", protocol_getName(value)];
            STLog(value, _descTemplate);
            _matchBlock = ^BOOL(ALCMatchBuilderBlockArgs) {
                return [builder.valueClass conformsToProtocol:value];
            };

        } else {
            _type = ALCModelSearchExpressionTypeString;
            _descTemplate = [NSString stringWithFormat:@"Qualifier '%@'", value];
            STLog(value, _descTemplate);
            _matchBlock = ^BOOL(ALCMatchBuilderBlockArgs) {
                return [builder.name isEqualToString:value];
            };
        }
    }
    return self;
}

-(id) cacheId {
    return _value;
}

-(NSString *) description {
    return [NSString stringWithFormat:_descTemplate, [_value description]];
}

#pragma mark - Equality

-(NSUInteger)hash {
    return [_value hash];
}

-(BOOL) isEqual:(id)object {
 return self == object
    || ([object isKindOfClass:[ALCQualifier class]] && [self isEqualToQualifier:object]);
}

-(BOOL) isEqualToQualifier:(ALCQualifier *) qualifier {
    return qualifier != nil
    && qualifier.type == _type
    && _type == ALCModelSearchExpressionTypeString ? [(NSString *)_value isEqualToString:qualifier.value]: qualifier.value == _value;
}

@end
