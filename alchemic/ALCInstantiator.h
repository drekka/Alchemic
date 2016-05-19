//
//  ALCObjectGenerator.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"
#import "ALCDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A protocol for classes that can create objects.
 */
@protocol ALCInstantiator <ALCResolvable>

/**
 The default name for storing the instantiator in the model.
 */
@property (nonatomic, strong, readonly) NSString *defaultModelKey;

/**
 The completion block that can be executed to finished the object from createObject.
 */
@property (nonatomic, assign, readonly) ALCObjectCompletion objectCompletion;

/**
 Called to instantiate an object.
 
 @return An instance of the object. Note that this will not have had any dependencies injected as yet. the completion block from objectCompletion will do that.
 */
-(id) createObject;

@end

NS_ASSUME_NONNULL_END
