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
@class ALCClassInitializerBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassBuilder : ALCAbstractBuilder

#pragma mark - Setting up

@property(nonatomic, strong) ALCClassInitializerBuilder *initializerBuilder;

-(void) addInjectionPointForArguments:(ALCVariableDependencyMacroProcessor *) arguments;

@end

NS_ASSUME_NONNULL_END
