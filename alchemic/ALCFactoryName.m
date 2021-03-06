//
//  ALCAsName.m
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCFactoryName.h>

@implementation ALCFactoryName

+(instancetype) withName:(NSString *) name {
    ALCFactoryName *asNameQualifier = [[ALCFactoryName alloc] init];
    asNameQualifier->_asName = name;
    return asNameQualifier;
}

@end
