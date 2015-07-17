//
//  ALCAsName.m
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCWithName.h>

@implementation ALCWithName

+(instancetype) withName:(NSString *) name {
    ALCWithName *asNameQualifier = [[ALCWithName alloc] init];
    asNameQualifier->_asName = name;
    return asNameQualifier;
}

@end
