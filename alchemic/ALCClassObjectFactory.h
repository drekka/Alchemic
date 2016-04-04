//
//  ALCClassObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCAbstractObjectFactory.h"

@protocol ALCDependency;
@class ALCClassObjectFactoryInitializer;

@interface ALCClassObjectFactory : ALCAbstractObjectFactory

@property (nonatomic, strong) ALCClassObjectFactoryInitializer *initializer;

-(void) registerDependency:(id<ALCDependency>) dependency forVariable:(Ivar) variable withName:(NSString *) variableName;

-(void) injectDependenciesIntoObject:(id) value;

@end
