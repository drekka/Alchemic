//
//  ALCIntoVariable.m
//  alchemic
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCIntoVariable.h"

@implementation ALCIntoVariable

+(instancetype) intoVariableWithName:(NSString *) name {
    ALCIntoVariable *intoVariableQualifier = [[ALCIntoVariable alloc] init];
    intoVariableQualifier->_variableName = name;
    return intoVariableQualifier;
}

@end
