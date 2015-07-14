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
    NSString *_descTemplate;
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
            _type = QualifierTypeClass;
            _descTemplate = [NSString stringWithFormat:@"Qualifier [%s]", class_getName(value)];
            STLog(value, _descTemplate);
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [builder.valueClass isSubclassOfClass:value];
            };

        } else if ([ALCRuntime objectIsAProtocol:value]) {
            _type = QualifierTypeProtocol;
            _descTemplate = [NSString stringWithFormat:@"Qualifier <%s>", protocol_getName(value)];
            STLog(value, _descTemplate);
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [builder.valueClass conformsToProtocol:value];
            };

        } else {
            _type = QualifierTypeString;
            _descTemplate = [NSString stringWithFormat:@"Qualifier '%@'", value];
            STLog(value, _descTemplate);
            _checkBlock = ^BOOL(id<ALCBuilder> builder) {
                return [builder.name isEqualToString:value];
            };
        }
    }
    return self;
}

-(BOOL) matchesBuilder:(id<ALCBuilder> __nonnull) builder {
    return _checkBlock(builder);
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
    && _type == QualifierTypeString ? [(NSString *)_value isEqualToString:qualifier.value]: qualifier.value == _value;
}

@end
