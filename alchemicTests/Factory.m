//
//  FactoryObject.m
//  alchemic
//
//  Created by Derek Clarkson on 25/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "Factory.h"
#import "Alchemic.h"
#import "Component.h"

@implementation Factory {
    int x;
}

register(asName(@"buildADateString"), returnType(NSString), createSelector(makeAString))

-(NSString *) makeAString {
    x++;
    return [NSString stringWithFormat:@"Factory string %i", x];
}

//(Component, makeAComponent1)

-(Component *) makeAComponent1 {
    return [[Component alloc] init];
}

//registerFactoryMethod(Component, makeAComponent2)

-(Component *) makeAComponent2 {
    return [[Component alloc] init];
}

@end
