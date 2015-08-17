//
//  ACArg.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCValueSource;
@protocol ALCMacro;

NS_ASSUME_NONNULL_BEGIN

/**
 An argument factory is a builder that generates ALCArgument instances.

 @discussion what type of ALCArgument is returned depends on the macros it is fed. So the basic flow for using this class is:
 
 1. Create an instance.
 2. Populated with one or more macros through the addMacro: method.
 3. Request an argument from the argument method.
 */
@interface ALCValueSourceFactory : NSObject

/**
 Default initializer

 @param argumentType The expected type of the argument. This is used when deciding what to return from resolving.

 @return And instance of this class.
 */
-(instancetype) initWithType:(Class) valueType NS_DESIGNATED_INITIALIZER;

/**
 The macros that have been stored in the factory.
 */
@property(nonatomic, strong, readonly) NSSet<id<ALCMacro>> *macros;

/**
 Add a macro to the set of macros.
 
 @param macro The macro to be added.
 */
-(void) addMacro:(id<ALCMacro>) macro;

/**
 Generates and returns a ALCValueSource instance based on the macros previously stored.
 */
-(id<ALCValueSource>) valueSource;

@end

NS_ASSUME_NONNULL_END
