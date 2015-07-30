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
 Flasgs which define what macros the processor will allow.
 */
typedef NS_OPTIONS(NSUInteger, ALCAllowedMacros){
	ALCAllowedMacrosFactory  = 1 << 0,
	ALCAllowedMacrosPrimary  = 1 << 1,
	ALCAllowedMacrosName     = 1 << 2,
	ALCAllowedMacrosValueDef = 1 << 3,
	ALCAllowedMacrosArg      = 1 << 4
};

NS_ASSUME_NONNULL_BEGIN

@interface ALCMacroProcessor : NSObject

@property (nonatomic, strong) NSString *asName;
@property (nonatomic, assign, readonly) BOOL isFactory;
@property (nonatomic, assign, readonly) BOOL isPrimary;

-(instancetype) initWithAllowedMacros:(NSUInteger) allowedMacros;

-(void) addMacro:(id<ALCMacro>) macro;

-(ALCValueSourceFactory *) valueSourceFactoryAtIndex:(NSUInteger) index;

-(NSUInteger) valueSourceCount;

@end

NS_ASSUME_NONNULL_END
