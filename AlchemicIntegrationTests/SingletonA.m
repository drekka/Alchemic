//
//  SingletonA.m
//  Alchemic
//
//  Created by Derek Clarkson on 8/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "SingletonA.h"
#import "NonManagedObject.h"

#import <Alchemic/Alchemic.h>

@implementation SingletonA

AcRegister(AcFactoryName(@"SingletonAName"))
AcInject(singletonB)

AcMethod(NonManagedObject, methodToGetNonManagedClass, AcFactoryName(@"NonManagedInstance"))
-(NonManagedObject *) methodToGetNonManagedClass {
    return [[NonManagedObject alloc] init];
}

@end
