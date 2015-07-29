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
@class ALCMethodBuilder;
#import "ALCSearchableBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassBuilder : ALCAbstractBuilder<ALCSearchableBuilder>

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithValueClass:(Class) valueClass NS_DESIGNATED_INITIALIZER;

-(void) addVariableInjection:(ALCVariableDependencyMacroProcessor *) variableMacroProcessor;

-(ALCClassInitializerBuilder *) createInitializerBuilderForSelector:(SEL) initializer;

-(ALCMethodBuilder *) createMethodBuilderForSelector:(SEL)selector valueClass:(Class) valueClass;

@end

NS_ASSUME_NONNULL_END
