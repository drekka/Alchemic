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

#import "ALCBuilder.h"
#import "ALCDependency.h"

@interface ALCAbstractBuilder : NSObject<ALCBuilder>

@property (nonatomic, weak, readonly) ALCContext *context;

// Override so it can be set.
@property (nonatomic, strong) id value;

@property(nonatomic, strong, readonly) NSArray<ALCDependency *> *dependencies;

-(instancetype) initWithContext:(__weak ALCContext *) context valueType:(ALCType *) valueType;

-(id) resolveValue;

@end
