//
//  SimpleObject.m
//  alchemic
//
//  Created by Derek Clarkson on 30/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "SimpleObject.h"
#import "Alchemic.h"

@implementation SimpleObject {
    int i;
}

registerSingletonWithName(@"abc")

registerFactoryMethodWithName(@"def", NSString, stringFactory)

-(NSString *) stringFactory {
    return [NSString stringWithFormat:@"String %i", i++];
}

registerFactoryMethod(SimpleObject, simpleObjectWithSimpleObject:, @[withClass(SimpleObject), withName(@"abc")])

-(SimpleObject *) simpleObjectWithSimpleObject:(SimpleObject *) simpleObject {
    return [[SimpleObject alloc] init];
}

@end
