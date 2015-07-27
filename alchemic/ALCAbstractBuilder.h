//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCMacroProcessor;

#import <Alchemic/ALCBuilder.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractBuilder : NSObject<ALCBuilder>

-(void) configureWithMacroProcessor:(id<ALCMacroProcessor>) macroProcessor;

/**
 Called to create the object by the instantiate method. This is overridden to create the objects. Instantiate manages it and general should not be overridden.
 */
-(id) instantiateObject;

/**
 Called to resolve dependencies after the value has been created.
 */
-(void) injectObjectDependencies:(id) object;

-(void) validateClass:(Class) aClass selector:(nonnull SEL)selector macroProcessor:(nonnull id<ALCMacroProcessor>)macroProcessor;

@end

NS_ASSUME_NONNULL_END