//
//  FactoryA.m
//  Alchemic
//
//  Created by Derek Clarkson on 23/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "FactoryA.h"

#import <Alchemic/Alchemic.h>

@implementation FactoryA

AcRegister(AcFactory)
AcInject(singletonB)

@end
