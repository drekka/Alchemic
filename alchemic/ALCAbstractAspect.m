//
//  ALCAbstractAspect.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/10/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCAbstractAspect.h>

@implementation ALCAbstractAspect

static BOOL _enabled;

+(void) setEnabled:(BOOL) enabled {
    _enabled = enabled;
}

+(BOOL) enabled {
    return _enabled;
}

@end
