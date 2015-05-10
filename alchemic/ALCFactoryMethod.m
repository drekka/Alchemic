//
//  ALCFactoryMethod.m
//  alchemic
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCFactoryMethod.h"
#import "ALCRuntime.h"
#import "ALCInstance.h"

@implementation ALCFactoryMethod 

-(instancetype) initWithContext:(__weak ALCContext *) context
                factoryInstance:(ALCInstance *) factoryInstance
                factorySelector:(SEL) factorySelector
                     returnType:(Class) returnTypeClass {

    self = [super initWithContext:context objectClass:returnTypeClass];
    if (self) {
        
        [ALCRuntime validateSelector:factorySelector withClass:factoryInstance.objectClass];

        // Locate the method.
        Method method = class_getInstanceMethod(factoryInstance.objectClass, factorySelector);
        if (method == NULL) {
            method = class_getClassMethod(factoryInstance.objectClass, factorySelector);
        }
        
        // Validate the number of arguments.
        
        self.name = [NSString stringWithFormat:@"%s::%s", class_getName(factoryInstance.objectClass), sel_getName(factorySelector)];
    }
    return self;
}

@end
