//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCObjectMetadata.h"

@class ALCContext;
@class ALCResolver;

@interface ALCAbstractModelObject : NSObject<ALCObjectMetadata>

@property(nonatomic, weak, readonly) ALCContext *context;
@property(nonatomic, strong, readonly) NSArray *dependencies;

/**
 Initialiser used when registering classes.
 */
-(instancetype) initWithContext:(__weak ALCContext *) context objectClass:(Class) objectClass;

-(void) addDependencyResolver:(ALCResolver *) dependency;

@end
