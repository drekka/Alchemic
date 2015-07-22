//
//  ALCMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCValueSource;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCMacroProcessor <NSObject>

@property (nonatomic, assign, readonly) Class parentClass;

-(void) addArgument:(id) argument;

-(id<ALCValueSource>) valueSourceAtIndex:(int) index;

-(void) validate;

@end

NS_ASSUME_NONNULL_END