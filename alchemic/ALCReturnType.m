//
//  ALCReturnType.m
//  alchemic
//
//  Created by Derek Clarkson on 6/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCReturnType.h"

@implementation ALCReturnType 

+(instancetype) returnTypeWithClass:(Class) returnTypeClass {
    ALCReturnType *returnType = [[ALCReturnType alloc] init];
    returnType->_returnType = returnTypeClass;
    return returnType;
}

@end
