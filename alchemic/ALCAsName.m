//
//  ALCAsName.m
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAsName.h"

@implementation ALCAsName

+(instancetype) asNameWithName:(NSString *) name {
    ALCAsName *asNameQualifier = [[ALCAsName alloc] init];
    asNameQualifier->_asName = name;
    return asNameQualifier;
}

@end
