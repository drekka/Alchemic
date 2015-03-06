//
//  ALCObjectInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCContext;

/**
 Protocol for classes that manage the onjection of dependencies into other objects.
 */
@protocol ALCDependencyResolver <NSObject>

-(void) resolveDependenciesInObject:(id) object usingContext:(ALCContext *) context;

@end
