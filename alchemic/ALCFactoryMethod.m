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

@implementation ALCFactoryMethod {
    __weak ALCInstance *_factoryInstance;
    SEL _factorySelector;
    NSArray *_argumentMatchers;
}

-(instancetype) initWithContext:(__weak ALCContext *) context
                factoryInstance:(ALCInstance *) factoryInstance
                factorySelector:(SEL) factorySelector
                     returnType:(Class) returnTypeClass
               argumentMatchers:(NSArray *) argumentMatchers {

    self = [super initWithContext:context objectClass:returnTypeClass];
    if (self) {
        
        [ALCRuntime validateSelector:factorySelector withClass:factoryInstance.objectClass];

        // Locate the method.
        Method method = class_getInstanceMethod(factoryInstance.objectClass, factorySelector);
        if (method == NULL) {
            method = class_getClassMethod(factoryInstance.objectClass, factorySelector);
        }
        
        // Validate the number of arguments.
        unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
        if (nbrArgs != [argumentMatchers count]) {
            @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                           reason:[NSString stringWithFormat:@"%s::%s - Expecting %lu argument matchers, got %lu", object_getClassName(factoryInstance.objectClass), sel_getName(factorySelector), nbrArgs, [argumentMatchers count]]
                                         userInfo:nil];
        }

        _factoryInstance = factoryInstance;
        _factorySelector = factorySelector;
        _argumentMatchers = argumentMatchers;
        self.name = [NSString stringWithFormat:@"%s::%s", class_getName(factoryInstance.objectClass), sel_getName(factorySelector)];
    }
    return self;
}

-(void) resolveDependencies {
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Factory method '%@' %s::%s (%s)", self.name, class_getName(_factoryInstance.objectClass), sel_getName(_factorySelector), class_getName(self.objectClass)];
}

@end
