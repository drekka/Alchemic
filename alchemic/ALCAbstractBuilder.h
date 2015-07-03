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

@property(nonatomic, strong, readonly) NSArray<ALCDependency *> *dependencies;

-(instancetype) initWithContext:(__weak ALCContext *) context valueClass:(Class) valueClass;

-(id) resolveValue;

@end
