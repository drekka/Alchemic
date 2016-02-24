//
//  ALCClassObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractObjectFactory.h"

@protocol ALCDependency;

@interface ALCClassObjectFactory : ALCAbstractObjectFactory

-(void) registerDependency:(id<ALCDependency>) dependency forVariable:(NSString *) variableName;

-(void) injectDependenciesIntoObject:(id) value;

@end
