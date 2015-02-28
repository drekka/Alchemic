//
//  SingletonObject.m
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "SingletonObject.h"
#import "Alchemic.h"
#import "InjectableObject.h"

@implementation SingletonObject {
    InjectableObject *_injObj;
}

registerSingleton();
inject(@"_injObj")

@end
