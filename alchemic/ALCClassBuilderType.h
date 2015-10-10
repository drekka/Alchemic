//
//  ALCBuilderType.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
#import "ALCAbstractBuilderType.h"
@class ALCValueSourceFactory;

NS_ASSUME_NONNULL_BEGIN

/**
 A builder strategy that is used to build classes.
 */
@interface ALCClassBuilderType : ALCAbstractBuilderType

/**
 Adds the definition of a variable in the class that is to be injected with a value.

 @param variable           The variable to be injected.
 @param valueSourceFactory A ALCValueSourceFactory that will be used to locate the value to inject.
 */
-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory;

@end

NS_ASSUME_NONNULL_END
