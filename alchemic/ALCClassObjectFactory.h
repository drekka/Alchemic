//
//  ALCClassObjectFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCAbstractObjectFactory.h"

@protocol ALCInjector;
@class ALCClassObjectFactoryInitializer;

@interface ALCClassObjectFactory : ALCAbstractObjectFactory

@property (nonatomic, strong) ALCClassObjectFactoryInitializer *initializer;

-(void) registerInjection:(id<ALCInjector>) injection forVariable:(Ivar) variable withName:(NSString *) variableName;

-(void) injectDependencies:(id) object;

@end
