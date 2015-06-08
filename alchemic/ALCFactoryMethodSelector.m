//
//  ALCFactoryMethodSelector.m
//  alchemic
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCFactoryMethodSelector.h"

@implementation ALCFactoryMethodSelector

+(instancetype) factoryMethodSelector:(SEL) methodSelector {
    ALCFactoryMethodSelector *factorySelectorQualifier = [[ALCFactoryMethodSelector alloc] init];
    factorySelectorQualifier->_factorySelector = methodSelector;
    return factorySelectorQualifier;
}

@end
