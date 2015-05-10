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
#import "ALCModelObject.h"

@interface ALCInstance : ALCModelObject

@property (nonatomic, assign) BOOL instantiate;

#pragma mark - Setting up

-(void) addDependency:(NSString *) inj, ...;

-(void) addDependency:(NSString *) inj withMatchers:(NSSet *) matchers;

-(void) addInitStrategy:(id<ALCInitStrategy>) initialisationStrategy;

@end
