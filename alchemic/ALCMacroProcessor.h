//
//  ALCMethodArgMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCMacro;
@class ALCValueSourceFactory;

/**
 Flags which define what macros the processor will allow.
 */
typedef NS_OPTIONS(NSUInteger, ALCAllowedMacros){
	/// Allow the factory macro to be used.
	ALCAllowedMacrosFactory  = 1 << 0,
	/// Alloc the primary macro to be used.
	ALCAllowedMacrosPrimary  = 1 << 1,
	/// Allow the with name macro to be used.
	ALCAllowedMacrosName     = 1 << 2,
	/// Allow the search and constant macros to be used.
	ALCAllowedMacrosValueDef = 1 << 3,
	/// Allow the Arg macro to be used.
	ALCAllowedMacrosArg      = 1 << 4
};

NS_ASSUME_NONNULL_BEGIN

/**
 All registrations make use of a ALCMacroProcessor instance to interpret the macro arguments passed in.
 */
@interface ALCMacroProcessor : NSObject

/// @name Properties

/// If the AcWithName(...) macro is passed then this will be populated with the value.
@property (nonatomic, strong) NSString *asName;

/// If the AcIsFactory macro is passed then this will be set to YES.
@property (nonatomic, assign, readonly) BOOL isFactory;

/// If the AcIsPrimary macro is passed then this will be set to YES.
@property (nonatomic, assign, readonly) BOOL isPrimary;

/// @name Tasks

/**
 Main initializer.
 
 @param allowedMacros One or more of the bit flags in ALCAllowedMacros. These flags define what macros the macro processor will accept via the addMacro: method.
 @return an instance of this class.
 */
-(instancetype) initWithAllowedMacros:(NSUInteger) allowedMacros;

-(void) addMacro:(id<ALCMacro>) macro;

-(ALCValueSourceFactory *) valueSourceFactoryAtIndex:(NSUInteger) index;

-(NSUInteger) valueSourceCount;

@end

NS_ASSUME_NONNULL_END
