//
//  ALCAbstractObjectFactory.m
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectFactory.h"

@implementation ALCAbstractObjectFactory

@synthesize name = _name;

+(id<ALCObjectFactory>) NoFactoryInstance {
    static id<ALCObjectFactory> _NoFactoryInstance;
    if (!_NoFactoryInstance) {
        _NoFactoryInstance = [[ALCAbstractObjectFactory alloc] init];
    }
    return _NoFactoryInstance;
}

@end
