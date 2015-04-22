//
//  AlchemicContext.h
//  alchemic
//
//  Created by Derek Clarkson on 15/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"
#import "ALCDependencyInjector.h"
#import "ALCMatcher.h"

@class ALCInstance;

@interface ALCContext : NSObject

#pragma mark - Configuration

/**
 Adds a ALCDependencyInjector to the list of injectors.
 */
-(void) addDependencyInjector:(id<ALCDependencyInjector>) dependencyinjector;

/**
 Adds a ALCObjectFactory to the list of object factories. Factories are checked in reverse order. The last registered object factory is the one asked first for an object.
 */
-(void) addObjectFactory:(id<ALCObjectFactory>) objectFactory;

#pragma mark - Lifecycle

-(void) start;

#pragma mark - Registering classes

-(void) addInstance:(ALCInstance *) instance;

#pragma mark - Manually injecting dependencies

-(void) injectDependencies:(id) object;

@end
