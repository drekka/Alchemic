//
//  SingletonObject.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "Component.h"
#import "Alchemic.h"
#import "InjectableObject.h"
#import "InjectableProtocol.h"

@implementation Component

registerComponent()
injectValues(@"injObj", @"injProto")

-(void) didResolveDependencies {
    NSLog(@"Resolved !!!");
}

@end
