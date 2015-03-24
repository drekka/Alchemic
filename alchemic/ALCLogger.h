//
//  ALCSimpleLogger.h
//  alchemic
//
//  Created by Derek Clarkson on 21/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCLogger;

/**
 Logging levels.
 */
typedef NS_OPTIONS(NSUInteger, AlchemicLogCategory){
    AlchemicLogCategoryCreation            = 1 << 0,
    AlchemicLogCategoryRegistrations       = 1 << 1,
    AlchemicLogCategoryDependencyResolving = 1 << 2,
    AlchemicLogCategoryConfiguration       = 1 << 3,
    AlchemicLogCategoryProxies             = 1 << 4,
    AlchemicLogCategoryRuntime             = 1 << 5
};

#define logCreation(template, ...) [ALCLogger logCategory:AlchemicLogCategoryCreation source:__PRETTY_FUNCTION__ line:__LINE__ message:template, ## __VA_ARGS__];

#define logRegistration(template, ...) [ALCLogger logCategory:AlchemicLogCategoryRegistrations source:__PRETTY_FUNCTION__ line:__LINE__ message:template, ## __VA_ARGS__];

#define logDependencyResolving(template, ...) [ALCLogger logCategory:AlchemicLogCategoryDependencyResolving source:__PRETTY_FUNCTION__ line:__LINE__ message:template, ## __VA_ARGS__];

#define logConfig(template, ...) [ALCLogger logCategory:AlchemicLogCategoryConfiguration source:__PRETTY_FUNCTION__ line:__LINE__ message:template, ## __VA_ARGS__];

#define logProxies(template, ...) [ALCLogger logCategory:AlchemicLogCategoryProxies source:__PRETTY_FUNCTION__ line:__LINE__ message:template, ## __VA_ARGS__];

#define logRuntime(template, ...) [ALCLogger logCategory:AlchemicLogCategoryRuntime source:__PRETTY_FUNCTION__ line:__LINE__ message:template, ## __VA_ARGS__];

@interface ALCLogger : NSObject

/**
 Turns on a category of logging.
 
 @param categorySwitch the switch.
 */
+(void) setLoggingSwitch:(AlchemicLogCategory) categorySwitch;

/**
 Logs a message.
 
 @param category        The category of the message.
 @param source          The source of the message.
 @param line            The line number of the source for the message.
 @param messageTemplate A standard NSString template for a string.
 */
+(void) logCategory:(AlchemicLogCategory) category
             source:(const char *) source
               line:(int) line
            message:(NSString *) messageTemplate, ...;

@end
