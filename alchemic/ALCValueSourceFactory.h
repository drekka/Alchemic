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

#import "ALCResolvable.h"
#import "ALCInternalMacros.h"

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
 The class of the value that the factory represents.
 */
@property (nonatomic, assign, readonly) Class valueType;

/**
 Returns a values source based on the factories state.
 */
@property (nonatomic, strong, readonly) id<ALCValueSource> valueSource;

/**
 The macros that have been stored in the factory.
 */
@property(nonatomic, strong, readonly) NSSet<id<ALCMacro>> *macros;

hideInitializer(init);

/**
 Default initializer

 @param valueType The class of the object that will be returned.

 @return And instance of this class.
 */
-(instancetype) initWithType:(Class) valueType NS_DESIGNATED_INITIALIZER;

/**
 Add a macro to the set of macros.
 
 @param macro The macro to be added.
 */
-(void) addMacro:(id<ALCMacro>) macro;

@end

NS_ASSUME_NONNULL_END
