//
//  SimpleObject.m
//  alchemic
//
//  Created by Derek Clarkson on 30/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "SimpleObject.h"
#import "Alchemic.h"

@implementation SimpleObject

registerSingleton
//registerComponentWithName(@"abc")

-(instancetype) init {
    self = [super init];
    if (self) {}
    return self;
}

registerFactoryMethod(simpleObject, SimpleObject)

-(SimpleObject *) simpleObject {
    return [[SimpleObject alloc] init];
}

registerFactoryMethod(simpleObject, SimpleObject, withClass(SimpleObject))

-(SimpleObject *) simpleObjectWithSImpleObject:(SimpleObject *) simpleObject {
    return [[SimpleObject alloc] init];
}

@end
