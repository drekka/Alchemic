//
//  FactoryObject.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "FactoryMethods.h"
#import "Component.h"
#import <Alchemic/Alchemic.h>

@implementation FactoryMethods {
    int x;
}

ACRegister(ACIsFactory, ACAsName(@"buildAString"), ACReturnType(NSString), ACSelector(makeAString));
-(NSString *) makeAString {
    x++;
    return [NSString stringWithFormat:@"Factory string %i", x];
}

ACRegister(ACIsFactory, ACAsName(@"buildAComponentString"), ACReturnType(NSString), ACSelector(makeAStringWithComponent:), ACWithClass(Component))
-(NSString *) makeAStringWithComponent:(Component *) component {
    x++;
    return [NSString stringWithFormat:@"Component Factory string %i", x];
}

@end
