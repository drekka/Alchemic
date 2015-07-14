//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCType;
@class ALCContext;
@class ALCDependency;

#import <Alchemic/ALCBuilder.h>

@interface ALCAbstractBuilder : NSObject<ALCBuilder>

@property (nonatomic, weak, readonly) ALCContext *context;

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                                   name:(NSString __nonnull *) name;

/**
 Called to create the object.
 */
-(nonnull id) instantiateObject;

/**
 Called to resolve dependencies after the value has been created.
 */
-(void) injectObjectDependencies:(id __nonnull) object;

@end
