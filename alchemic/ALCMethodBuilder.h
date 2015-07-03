//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@class ALCClassBuilder;

@interface ALCMethodBuilder : ALCAbstractBuilder

@property (nonatomic, strong, readonly) NSArray *argumentMatchers;

-(instancetype) initWithContext:(__weak ALCContext *) context
                     buildClass:(Class) buildClass
            factoryClassBuilder:(ALCClassBuilder *) factoryClassBuilder
                factorySelector:(SEL) factorySelector
               argumentMatchers:(NSArray<id<ALCMatcher>> *) argumentMatchers NS_DESIGNATED_INITIALIZER;

@end
