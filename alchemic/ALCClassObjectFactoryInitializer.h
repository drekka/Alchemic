//
//  ALCObjectFactoryInitializer.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectGenerator.h"

@protocol ALCDependency;
@class ALCClassObjectFactory;

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassObjectFactoryInitializer : ALCAbstractObjectGenerator

-(instancetype) initWithClass:(Class) objectClass NS_UNAVAILABLE;

-(instancetype) initWithObjectFactory:(ALCClassObjectFactory *) objectFactory
                          initializer:(SEL) initializer
                                 args:(NSArray<id<ALCDependency>> *) arguments NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END