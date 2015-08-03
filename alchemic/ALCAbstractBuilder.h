//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCMacroProcessor;
@class ALCDependency;

#import "ALCBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractBuilder : NSObject<ALCBuilder>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) BOOL createOnBoot;

// If the builder is to be regarded as a primary builder.
@property (nonatomic, assign) BOOL primary;

// If the builder is a factory.
@property (nonatomic, assign) BOOL factory;

@property (nonatomic, strong) ALCMacroProcessor *macroProcessor;

@property (nonatomic, strong, readonly) NSMutableArray<ALCDependency *> *dependencies;

/**
 Called to create the object by the instantiate method. This is overridden to create the objects. Instantiate manages it and general should not be overridden.
 */
-(id) instantiateObject;

-(void) validateClass:(Class) aClass selector:(SEL)selector macroProcessor:(ALCMacroProcessor *) macroProcessor;

@end

NS_ASSUME_NONNULL_END