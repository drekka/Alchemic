//
//  ACArg.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCValueSource;
@protocol ALCValueDefMacro;

NS_ASSUME_NONNULL_BEGIN

/**
 A value source factory is a builder that generates ALCValueSource instances.

 @discussion what type of ALCValueSource is returned depends on the macros it is fed. So the basic flow for using this class is:
 
 1. Create an instance.
 2. Populated with one or more macros through the addMacro: method.
 3. Request a value source from the valueSource method.
 */
@interface ALCValueSourceFactory : NSObject

/**
 The macros that have been store in the factory.
 */
@property(nonatomic, strong, readonly) NSSet<id<ALCValueDefMacro>> *macros;

/**
 Add a macro to the set of macros.
 
 @param macro The macro to be added.
 */
-(void) addMacro:(id<ALCValueDefMacro>) macro;

/**
 Generates and returns a ALCValueSource instance based on the macros previously stored. 
 */
-(id<ALCValueSource>) valueSource;

@end

NS_ASSUME_NONNULL_END
