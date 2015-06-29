//
//  STConfig.m
//  StoryTeller
//
//  Created by Derek Clarkson on 22/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <PEGKit/PEGKit.h>

#import <StoryTeller/STConfig.h>
#import <StoryTeller/STStoryTeller.h>
#import <StoryTeller/STConsoleLogger.h>

@interface STConfig ()
@property (nonatomic, strong) NSArray<NSString *> *activeLogs;
@property (nonatomic, strong) NSString *loggerClass;
@end

@implementation STConfig {
    // This is mainly used to stop EXC_BAD_ACCESS's occuring when verifying results in tests.
    // Bug in OCMock: https://github.com/erikdoe/ocmock/issues/147
    id<STLogger> _currentLogger;

    PKAssembly *result;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _activeLogs = @[];
        _loggerClass = NSStringFromClass([STConsoleLogger class]);
        [self configurefromFile];
        [self configurefromArgs];
    }
    return self;
}

-(void) configurefromArgs {
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo.arguments enumerateObjectsUsingBlock:^(NSString * __nonnull arg, NSUInteger idx, BOOL * __nonnull stop) {
        NSArray __nonnull *args = [arg componentsSeparatedByString:@"="];
        if ([args count] == 2) {
            [self setValue:args[1] forKeyPath:args[0]];
        }
    }];
}

-(void) configurefromFile {

    // Get the config file.
    NSArray<NSBundle *> *appBundles = [NSBundle allBundles];
    NSURL *configUrl = nil;
    for (NSBundle *bundle in appBundles) {
        configUrl = [bundle URLForResource:@"StoryTellerConfig" withExtension:@"json"];
        if (configUrl != nil) {
            break;
        }
    }

    if (configUrl != nil) {
        NSError *error = nil;
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:configUrl]
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&error];
        if (error != nil) {
            @throw [NSException exceptionWithName:@"StoryTeller" reason:[error localizedFailureReason] userInfo:nil];
        }

        [self setValuesForKeysWithDictionary:jsonData];
    }
}

-(void) configure:(STStoryTeller __nonnull *) storyTeller {

    Class loggerClass = objc_lookUpClass([_loggerClass UTF8String]);
    id<STLogger> newLogger = [[loggerClass alloc] init];
    if (newLogger == nil) {
        @throw [NSException exceptionWithName:@"StoryTeller" reason:[NSString stringWithFormat:@"Unknown class '%@'", _loggerClass] userInfo:nil];
    }
    storyTeller.logger = newLogger;
    _currentLogger = newLogger;

    [_activeLogs enumerateObjectsUsingBlock:^(NSString * __nonnull expression, NSUInteger idx, BOOL * __nonnull stop) {
        [storyTeller startLogging:expression];
    }];
}

// Override KVC method to handle arrays in active logs.
-(void) setValue:(nullable id)value forKey:(nonnull NSString *)key {
    if ([key isEqualToString:@"activeLogs"]) {
        [super setValue:[value componentsSeparatedByString:@","] forKey:key];
        return;
    }
    [super setValue:value forKey:key];
}

// DIsabled default so we can load settings without having to check the names of properties.
-(void) setValue:(nullable id)value forUndefinedKey:(nonnull NSString *)key {
}

@end
