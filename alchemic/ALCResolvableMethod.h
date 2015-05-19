//
//  ALCFactoryMethod.h
//  alchemic
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractResolvable.h"

@class ALCResolvableObject;

@interface ALCResolvableMethod : ALCAbstractResolvable

@property (nonatomic, strong) NSArray *argumentMatchers;

-(instancetype) initWithContext:(__weak ALCContext *) context
                factoryInstance:(ALCResolvableObject *) factoryInstance
                factorySelector:(SEL) factorySelector
                     returnType:(Class) returnTypeClass
               argumentMatchers:(NSArray *) argumentMatchers;

@end
