//
//  ALCMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCMacro;
@class ALCValueSourceFactory;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCMacroProcessor <NSObject>

-(void) addMacro:(id<ALCMacro>) macro;

-(ALCValueSourceFactory *) valueSourceFactoryForIndex:(NSUInteger) index;

-(NSUInteger) valueSourceCount;

-(void) validate;

@end

NS_ASSUME_NONNULL_END