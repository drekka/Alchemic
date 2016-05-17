//
//  SingletonC.m
//  Alchemic
//
//  Created by Derek Clarkson on 4/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "Database.h"

#import <Alchemic/Alchemic.h>

@implementation Database

AcInject(ui)

AcInitializer(initWithInt:, AcInt(5))
-(instancetype) initWithInt:(int) aInt {
    self = [super init];
    if (self) {
        _aInt = aInt;
    }
    return self;
}

@end
