//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelObject.h"

@class ALCContext;
@class ALCDependencyResolver;

@interface ALCAbstractModelObject : NSObject<ALCModelObject>

@property(nonatomic, weak, readonly) ALCContext *context;
@property(nonatomic, strong, readonly) NSArray *dependencies;

/**
 Initialiser used when registering classes.
 */
-(instancetype) initWithContext:(__weak ALCContext *) context objectClass:(Class) objectClass;

-(void) addDependencyResolver:(ALCDependencyResolver *) dependency;

@end
