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

#import <Alchemic/ALCBuilder.h>
#import <Alchemic/ALCDependency.h>

@interface ALCAbstractBuilder : NSObject<ALCBuilder>

@property (nonatomic, weak, readonly) ALCContext *context;

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                                   name:(NSString __nonnull *) name;

-(nullable id) resolveValue;

@end
