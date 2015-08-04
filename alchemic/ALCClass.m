//
//  ALCClassMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>

#import "ALCClass.h"
#import "ALCBuilder.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClass

+(instancetype) withClass:(Class) aClass {
    ALCClass *withClass = [[ALCClass alloc] init];
    withClass->_aClass = aClass;
    return withClass;
}

-(int) priority {
    return 0;
}

-(id) cacheId {
    return _aClass;
}

-(BOOL) matches:(id<ALCBuilder>) builder {
    return [builder.valueClass isSubclassOfClass:_aClass];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[%s]", class_getName(_aClass)];
}

#pragma mark - Equality

-(NSUInteger)hash {
    return [_aClass hash];
}

-(BOOL) isEqual:(id)object {
    return self == object
    || ([object isKindOfClass:[ALCClass class]] && [self isEqualToClass:object]);
}

-(BOOL) isEqualToClass:(nonnull ALCClass *)withClass {
    return withClass != nil && withClass.aClass == _aClass;
}

@end

NS_ASSUME_NONNULL_END