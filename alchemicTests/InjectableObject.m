//
//  InjectableObject.m
//  alchemic
//
//  Created by Derek Clarkson on 12/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "InjectableObject.h"
#import "Alchemic.h"

@interface InjectableObject ()
@property (nonatomic, strong) NSString *privateString;
@end

@implementation InjectableObject {
    NSString *_stringIVar;
}

registerSingleton();
//inject(@"_stringIVar");

-(instancetype) init {
    self = [super init];
    if (self) {
        _stringIVar = @"abc";
    }
    return self;
}

@end
