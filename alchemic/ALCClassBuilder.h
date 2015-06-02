//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInitStrategy.h"
#import "ALCContext.h"
#import "ALCAbstractBuilder.h"

@interface ALCClassBuilder : ALCAbstractBuilder

#pragma mark - Setting up

-(void) addInjectionPoint:(NSString *) inj, ...;

-(void) addInjectionPoint:(NSString *) inj withMatchers:(NSSet *) matchers;

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy;

#pragma mark - Creation

-(id) instantiate;

-(void) injectDependenciesInto:(id) object;

@end
