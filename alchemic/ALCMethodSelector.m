//
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCMethodSelector.h>

@implementation ALCMethodSelector

+(instancetype) methodSelector:(SEL) methodSelector {
    ALCMethodSelector *factorySelectorQualifier = [[ALCMethodSelector alloc] init];
    factorySelectorQualifier->_factorySelector = methodSelector;
    return factorySelectorQualifier;
}

@end
