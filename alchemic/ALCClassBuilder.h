//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCAbstractBuilder.h"
@class ALCMacroProcessor;
@class ALCClassInitializerBuilder;
@class ALCMethodBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassBuilder : ALCAbstractBuilder

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithValueClass:(Class) valueClass NS_DESIGNATED_INITIALIZER;

-(void) addVariableInjection:(Ivar) variable macroProcessor:(ALCMacroProcessor *) macroProcessor;

@end

NS_ASSUME_NONNULL_END
