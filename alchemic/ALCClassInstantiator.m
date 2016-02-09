//
//  ALCClassInstantiator.m
//  Alchemic
//
//  Created by Derek Clarkson on 1/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCClassInstantiator.h"
#import "ALCObjectFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClassInstantiator

-(id)instantiateForFactory:(id<ALCObjectFactory>) objectFactory {
    return [[objectFactory.objectClass alloc] init];
}

@end

NS_ASSUME_NONNULL_END
