//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCAbstractBuilder.h"
@class ALCVariableDependencyMacroProcessor;
@protocol ALCInitStrategy;

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassBuilder : ALCAbstractBuilder

#pragma mark - Setting up

-(void) addInjectionPointForArguments:(ALCVariableDependencyMacroProcessor *) arguments;

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy;

@end

NS_ASSUME_NONNULL_END
