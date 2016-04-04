//
//  ALCMethodObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectFactory.h"
@class ALCClassObjectFactory;
@protocol ALCDependency;

NS_ASSUME_NONNULL_BEGIN

@interface ALCMethodObjectFactory : ALCAbstractObjectFactory

-(instancetype) initWithClass:(Class)objectClass NS_UNAVAILABLE;

-(instancetype) initWithClass:(Class)objectClass
          parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                     selector:(SEL) selector
                         args:(nullable NSArray<id<ALCDependency>> *) arguments NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
