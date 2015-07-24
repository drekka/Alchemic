//
//  FactoryObject.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "FactoryMethods.h"
#import <Alchemic/Alchemic.h>
#import "Component.h"

@implementation FactoryMethods {
    int x;
}

AcMethod(NSString, makeAString, ACIsFactory, AcWithName(@"buildAString"));
-(NSString *) makeAString {
    x++;
    return [NSString stringWithFormat:@"Factory string %i", x];
}

AcMethod(NSString, makeAStringWithComponent:, ACIsFactory, AcWithName(@"buildAComponentString"), AcArg(NSString, AcClass(Component)))
-(NSString *) makeAStringWithComponent:(Component *) component {
    x++;
    return [NSString stringWithFormat:@"Component Factory string %i", x];
}

@end
