//
//  ALCClassBuilder.h
//  alchemic
//
//  Created by Derek Clarkson on 1/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCAbstractBuilder.h"

@class ALCValueSourceFactory;

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassBuilder : ALCAbstractBuilder

/**
 Adds a variable injection to the builder.

 @discussion This is used to register variable dependencies which are injected int0 created objects.

 @param variable           The name of the variable or property to be injected.
 @param valueSourceFactory A ALCValueSourceFactory loaded with the macros which define the value source.
 */
-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory;

/**
 Used to manually populate dependencies in an object not created by Alchemic.

 @param object The object which needs dependencies injected.
 */
-(void)injectDependencies:(id) object;

@end

NS_ASSUME_NONNULL_END
