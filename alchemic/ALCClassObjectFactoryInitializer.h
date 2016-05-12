//
//  ALCObjectFactoryInitializer.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCInstantiator.h"

@class ALCClassObjectFactory;
@protocol ALCDependency;

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassObjectFactoryInitializer : NSObject<ALCInstantiator>

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithObjectFactory:(ALCClassObjectFactory *) objectFactory
                          setInitializer:(SEL) initializer
                                 args:(NSArray<id<ALCDependency>> *) arguments NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
