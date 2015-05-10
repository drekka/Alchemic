//
//  ALCAbstractDependencyInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCAbstractClass.h"
#import "ALCDependencyInjector.h"

@interface ALCAbstractDependencyInjector : NSObject<ALCAbstractClass, ALCDependencyInjector>

/**
 Higher numbers mean the injector will be used first.
 */
@property (nonatomic, assign, readonly) int order;

-(void) injectObject:(id) object variable:(Ivar) variable withValue:(id) value;

@end
