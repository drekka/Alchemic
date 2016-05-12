//
//  TopObject.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "TopThing.h"
#import "NestedThing.h"

@implementation TopThing

-(instancetype) initWithNoArgs {
    self = [super init];
    if (self) {
        _aString = @"abc";
    }
    return self;
}

-(instancetype) initWithString:(NSString *) aString {
    self = [super init];
    if (self) {
        _aString = aString;
    }
    return self;
}

-(instancetype) initWithString:(NSString *) aString andInt:(int) aInt {
    self = [self initWithString:aString];
    if (self) {
        _aInt = aInt;
    }
    return self;
}

-(instancetype) initWithAnotherThing:(AnotherThing *) anotherThing {
    self = [super init];
    if (self) {
        _anotherThing = anotherThing;
    }
    return self;
}

-(instancetype) initWithNestedThings:(NSArray<NestedThing *> *) nestedThings {
    self = [super init];
    if (self) {
        _arrayOfNestedThings = nestedThings;
    }
    return self;
}

+(instancetype) classCreateWithString:(NSString *) aString {
    return [[TopThing alloc] initWithString:aString];
}

-(NestedThing *) nestedThingFactoryMethod {
    return [self nestedThingFactoryMethodWithString:@"abc" andInt:5];
}

-(NestedThing *) nestedThingFactoryMethodWithString:(NSString *) aString {
    return [self nestedThingFactoryMethodWithString:aString andInt:5];
}

-(NestedThing *) nestedThingFactoryMethodWithString:(NSString *) aString andInt:(int) aInt {
    NestedThing *thing = [[NestedThing alloc] init];
    thing.aInt = aInt;
    thing.aString = aString;
    return thing;
}

@end
