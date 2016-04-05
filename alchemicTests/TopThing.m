//
//  TopObject.m
//  Alchemic
//
//  Created by Derek Clarkson on 14/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "TopThing.h"

@implementation TopThing

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

-(instancetype) factoryMethodWithString:(NSString *) aString {
    return [[TopThing alloc] initWithString:aString];
}

-(instancetype) factoryMethodWithString:(NSString *) aString andInt:(int) aInt {
    TopThing *thing = [[TopThing alloc] initWithString:aString];
    thing.aInt = aInt;
    return thing;
}

@end
