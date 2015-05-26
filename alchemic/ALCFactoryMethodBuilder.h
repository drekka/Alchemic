//
//  ALCFactoryMethod.h
//  alchemic
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@class ALCClassBuilder;

@interface ALCFactoryMethodBuilder : ALCAbstractBuilder

@property (nonatomic, strong, readonly) NSArray *argumentMatchers;

-(instancetype) initWithContext:(__weak ALCContext *) context
                      valueType:(ALCType *) valyeType
            factoryClassBuilder:(ALCClassBuilder *) factoryClassBuilder
                factorySelector:(SEL) factorySelector
               argumentMatchers:(NSArray *) argumentMatchers NS_DESIGNATED_INITIALIZER;

@end
