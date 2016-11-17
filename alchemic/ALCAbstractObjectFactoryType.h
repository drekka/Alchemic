//
//  ALCAbstractObjectFactoryType.h
//  Alchemic
//
//  Created by Derek Clarkson on 20/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCObjectFactoryType.h>

@protocol ALCObjectFactory;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectFactoryType : NSObject<ALCObjectFactoryType>

/**
 Unused.

 @return An instance of the type strategy.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Designed initializer.

 @param objectFactory A weak reference to the parent object factory. Mostly just used for build error text when throwing exceptions.
 @return An instance of this class.
 */
-(instancetype) initWithFactory:(__weak id<ALCObjectFactory>) objectFactory NS_DESIGNATED_INITIALIZER;

/**
 A weak reference to the owning object factory. 
 */
@property (nonatomic, weak, readonly) id<ALCObjectFactory> objectFactory;

-(NSString *) descriptionWithType:(NSString *) type;

@end

NS_ASSUME_NONNULL_END
