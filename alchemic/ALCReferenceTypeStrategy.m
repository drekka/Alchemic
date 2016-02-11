//
//  ALCFactoryTypeReference.m
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCReferenceTypeStrategy.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCReferenceTypeStrategy

@synthesize object = _object;

-(id)value {
    if (_object == nil) {
        @throw [NSException exceptionWithName:@"AlchemicReferenceObjectNotSet"
                                       reason:str(@"%@ Builder is marked as a Reference to an external value, but value has not been set.", self)
                                     userInfo:nil];
    }
    return _object;
}

-(bool) resolved {
    return _object != nil;
}

@end

NS_ASSUME_NONNULL_END
