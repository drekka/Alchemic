//
//  ALCProtocolMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCProtocolMatcher.h"
#import "ALCObjectInstance.h"
@import ObjectiveC;
#import "ALCLogger.h"

@implementation ALCProtocolMatcher {
    Protocol *_protocol;
}

-(instancetype) initWithProtocol:(Protocol *) protocol {
    self = [super init];
    if (self) {
        logRegistration(@"Creating protocol matcher: %s", protocol_getName(protocol));
        _protocol = protocol;
    }
    return self;
}

-(BOOL) matches:(ALCObjectInstance *)instance withName:(NSString *) name {
    return class_conformsToProtocol(instance.objectClass, _protocol);
}

@end
