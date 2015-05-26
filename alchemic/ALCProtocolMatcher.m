//
//  ALCProtocolMatcher.m
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCProtocolMatcher.h"
#import "ALCClassBuilder.h"
@import ObjectiveC;
#import "ALCType.h"

@implementation ALCProtocolMatcher {
    Protocol *_protocol;
}

+(instancetype) matcherWithProtocol:(Protocol *) protocol {
    ALCProtocolMatcher *matcher = [[ALCProtocolMatcher alloc] init];
    matcher->_protocol = protocol;
    return matcher;
}

-(BOOL) matches:(id <ALCBuilder>) builder withName:(NSString *) name {
    return [builder.valueType typeConformsToProtocol:_protocol];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Protocol matcher: %s", protocol_getName(_protocol)];
}

@end
