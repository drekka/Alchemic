//
//  ALCFactoryTypeReference.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCObjectFactoryTypeReference.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCObjectFactoryTypeReference

@synthesize object = _object;

-(id) object {
    if (!self.ready) {
        throwException(@"AlchemicReferencedObjectNotSet", @"%@ is a reference factory which has not had a value set.", self);
    }
    return _object;
}

-(BOOL) ready {
    return _object != nil;
}

@end

NS_ASSUME_NONNULL_END
