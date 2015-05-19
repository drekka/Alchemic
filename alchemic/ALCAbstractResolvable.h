//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCResolvable.h"
#import "ALCValueProcessor.h"

@class ALCContext;
@class ALCDependency;

@interface ALCAbstractResolvable : NSObject<ALCResolvable>

@property(nonatomic, weak, readonly) ALCContext *context;
@property(nonatomic, strong, readonly) NSArray *dependencies;
@property(nonatomic, strong, readonly) id<ALCValueProcessor> valueProcessor;

/**
 Initialiser used when registering classes.
 */
-(instancetype) initWithContext:(__weak ALCContext *) context objectClass:(Class) objectClass;

-(void) addDependencyResolver:(ALCDependency *) dependency;

@end
