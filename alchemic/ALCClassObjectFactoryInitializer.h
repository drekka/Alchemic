//
//  ALCObjectFactoryInitializer.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCResolvable.h>
#import <Alchemic/ALCInstantiator.h>

@class ALCClassObjectFactory;
@protocol ALCDependency;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines an initializer to be used when a ALCClassObjectFactory is instantiating a object.
 */
@interface ALCClassObjectFactoryInitializer : NSObject<ALCResolvable, ALCInstantiator>

/**
 Unused initializer.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default initializer.
 
 @param objectFactory The ALCClassObjectFactory that describes the class to be instantiated.
 @param initializer   The initializer to call.
 @param arguments     A NSArray of 
 
 @return <#return value description#>
 */
-(instancetype) initWithObjectFactory:(ALCClassObjectFactory *) objectFactory
                       setInitializer:(SEL) initializer
                                 args:(NSArray<id<ALCDependency>> *) arguments NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
