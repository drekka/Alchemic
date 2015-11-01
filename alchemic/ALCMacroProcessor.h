//
//  ALCMethodArgMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCMacro;
@protocol ALCValueSource;

/**
 Flags which define what macros the processor will allow.
 */
typedef NS_OPTIONS(NSUInteger, ALCAllowedMacros) {
    /// Allow the factory macro to be used.
    ALCAllowedMacrosFactory = 1 << 0,
    /// Alloc the primary macro to be used.
    ALCAllowedMacrosPrimary = 1 << 1,
    /// Allow the with name macro to be used.
    ALCAllowedMacrosName = 1 << 2,
    /// Allow the Arg macro to be used.
    ALCAllowedMacrosArg = 1 << 3,
    /// Alloc the primary macro to be used.
    ALCAllowedMacrosExternal = 1 << 4
};

NS_ASSUME_NONNULL_BEGIN

/**
 All registrations make use of a ALCMacroProcessor instance to interpret the
 macro arguments passed in.
 */
@interface ALCMacroProcessor : NSObject

/// @name Properties

/// If the AcWithName(...) macro is passed then this will be populated with the value.
@property (nonatomic, strong, readonly) NSString *asName;

/// If the AcFactory macro is passed then this will be set to YES.
@property (nonatomic, assign, readonly) BOOL isFactory;

/// If the AcPrimary macro is passed then this will be set to YES.
@property (nonatomic, assign, readonly) BOOL isPrimary;

/// If the AcExternal macro is passed then this will be set to YES.
@property (nonatomic, assign, readonly) BOOL isExternal;

/// @name Tasks

/**
 Main initializer.

 @param allowedMacros One or more of the bit flags in ALCAllowedMacros. These
 flags define what macros the macro processor will accept via the addMacro:
 method.
 @return an instance of this class.
 */
- (instancetype)initWithAllowedMacros:(NSUInteger)allowedMacros;

/**
 Adds a macro to the list of macros the processor is managing.

 @param macro The macro to add.
 */
- (void)addMacro:(id<ALCMacro>)macro;

/**
 returns the value source for a specific argument index.

 @discussion All macros which define search expressions or values are grouped
 according to the argument index used to match to selectors for method builders.
 If the macro processor is being used to processor macros for other builders
 which do no have selectors, then they are all grouped up under index 0.

 @param index the argument index.

 */
- (id<ALCValueSource>)valueSourceAtIndex:(NSUInteger)index;

/**
 How many value sources are in the array of selector argument values sources.
 */
- (NSUInteger)valueSourceCount;

@end

NS_ASSUME_NONNULL_END
