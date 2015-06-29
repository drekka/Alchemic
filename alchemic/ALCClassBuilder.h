//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCAbstractBuilder.h"
#import "ALCInitStrategy.h"

@interface ALCClassBuilder : ALCAbstractBuilder

#pragma mark - Setting up

-(void) addInjectionPoint:(NSString *) inj withMatchers:(NSSet *) matchers;

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy;

-(void) injectDependenciesInto:(id) object;

@end
