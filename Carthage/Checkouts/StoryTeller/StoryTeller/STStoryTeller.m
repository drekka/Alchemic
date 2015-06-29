//
//  StoryTeller.m
//  StoryTeller
//
//  Created by Derek Clarkson on 18/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/STStoryTeller.h>
#import <StoryTeller/STConfig.h>
#import "STMatcher.h"
#import "STExpressionMatcherFactory.h"

@implementation STStoryTeller {
    NSMutableSet *_activeKeys;
    NSMutableSet<id<STMatcher>> *_logMatchers;
    STConfig *_config;
    STExpressionMatcherFactory *_expressionMatcherFactory;
}

static STStoryTeller *__storyTeller;

#pragma mark - Lifecycle

+(void) initialize {
#ifndef DISABLE_STORY_TELLER
    __storyTeller = [[STStoryTeller alloc] init];
#endif
}

+(STStoryTeller __nonnull *) storyTeller {
    return __storyTeller;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _activeKeys = [[NSMutableSet alloc] init];
        _logMatchers = [[NSMutableSet alloc] init];
        _expressionMatcherFactory = [[STExpressionMatcherFactory alloc] init];
        _config = [[STConfig alloc] init];
        [_config configure:self];
    }
    return self;
}

#pragma mark - Story teller

-(void) reset {
    [STStoryTeller initialize];
}

#pragma mark - Activating logging

-(void) logAll {
    _logAll = YES;
    _logRoots = NO;
    [_logMatchers removeAllObjects];
}

-(void) logRoots {

    if (_logAll) {
        return;
    }

    _logRoots = YES;
    [_logMatchers removeAllObjects];
}

-(void) startLogging:(NSString __nonnull *) keyExpression {

    NSError *error = nil;
    id<STMatcher> matcher = [_expressionMatcherFactory parseExpression:keyExpression
                                                                 error:&error];
    if (matcher) {
        [_logMatchers addObject:matcher];
    }
}

#pragma mark - Activating

-(int) numberActiveScopes {
    return (int)[_activeKeys count];
}

-(void) startScope:(id __nonnull) key {
    [_activeKeys addObject:key];
}

-(void) endScope:(id __nonnull) key {
    [_activeKeys removeObject:key];
}

-(BOOL) isScopeActive:(id __nonnull) key {
    return [_activeKeys containsObject:key];
}

#pragma mark - Logging

-(void) record:(id __nonnull) key method:(const char __nonnull *) methodName lineNumber:(int) lineNumber message:(NSString __nonnull *) messageTemplate, ... {

    // Only continue if the key is being logged.
    if (![self isLogging:key]) {
        return;
    }

    // Assemble the main message.
    va_list args;
    va_start(args, messageTemplate);
    NSString *msg = [[NSString alloc] initWithFormat:messageTemplate arguments:args];
    va_end(args);

    // And give it to the scribe.
    [self.logger writeMessage:msg
                   fromMethod:methodName
                   lineNumber:lineNumber
                          key:key];
}

-(void) execute:(id __nonnull) key block:(void (^ __nonnull)(id __nonnull)) block {

    // Only continue if the key is being logged.
    if (![self isLogging:key]) {
        return;
    }

    block(key);
}

-(BOOL) isLogging:(id) key {

    // Check the bypass and active keys.
    if (_logAll || [self isKeyActive:key]) {
        return YES;
    }

    // If logRoot is in effect we need to log as long as there are no scopes.
    if (_logRoots && [_activeKeys count] == 0) {
        return YES;
    }

    // If any of the active keys are logging then we also fire.
    for (id scopeKey in _activeKeys) {
        if ([self isKeyActive:scopeKey]) {
            return YES;
        }
    }

    return NO;
}

-(BOOL) isKeyActive:(id) key {
    for (id<STMatcher> matcher in _logMatchers) {
        if ([matcher matches:key]) {
            return YES;
        }
    }
    return NO;
}

@end
