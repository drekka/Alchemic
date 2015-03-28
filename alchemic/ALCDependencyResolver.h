//
//  ALCObjectInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 20/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependency;

/**
 Protocol for classes that manage the onjection of dependencies into other objects.
 */
@protocol ALCDependencyResolver <NSObject>

/**
 Default initialiser
 
 @param context the ALCContext that owns the resolver.
 
 @return an instance of the resolver.
 */
-(instancetype) initWithModel:(NSDictionary *) model;

-(NSDictionary *) resolveDependencyWithClass:(Class) aClass
                                   protocols:(NSArray *) protocols
                                        name:(NSString *) name;

@end
