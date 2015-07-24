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

@interface ALCValueSourceFactory : NSObject

@property(nonatomic, strong, readonly) NSSet<id<ALCValueDefMacro>> *macros;

-(void) addMacro:(id<ALCValueDefMacro>) macro;

-(id<ALCValueSource>) valueSource;

-(void) validate;

@end

NS_ASSUME_NONNULL_END
