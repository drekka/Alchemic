//
//  ALCClassInstantiator.m
//  Alchemic
//
//  Created by Derek Clarkson on 1/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCClassInstantiator.h"
#import "ALCValueFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClassInstantiator

-(id)instantiateForFactory:(id<ALCValueFactory>)valueFactory {
    return [[valueFactory.valueClass alloc] init];
}

@end

NS_ASSUME_NONNULL_END
