//
//  ALCClassObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectFactory.h"

@protocol ALCResolvable;

@interface ALCClassObjectFactory : ALCAbstractObjectFactory

-(void) registerDependency:(id<ALCResolvable>) dependency forVariable:(NSString *) variableName;

-(void) injectDependenciesIntoObject:(id) value;

@end
