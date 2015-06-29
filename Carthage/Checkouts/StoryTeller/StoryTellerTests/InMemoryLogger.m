//
//  InMemoryScribe.m
//  StoryTeller
//
//  Created by Derek Clarkson on 18/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "InMemoryLogger.h"

@implementation InMemoryLogger {
    NSMutableArray<NSString *> *_log;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _log = [@[] mutableCopy];
    }
    return self;
}

-(void)writeMessage:(NSString *)message {
    [_log addObject:message];
    printf("%s\n", [message UTF8String]);
}

-(NSArray *) log {
    return _log;
}

@end
