//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCInstance : NSObject

@property (nonatomic, assign, readonly) Class forClass;
@property (nonatomic, strong) id finalObject;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) BOOL instantiate;
@property (nonatomic, assign) BOOL primaryInstance;

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) class;

#pragma mark -Setting up

-(void) addDependency:(NSString *) inj, ...;

-(void) addDependency:(NSString *) inj withMatchers:(NSArray *) matchers;

-(void) resolveDependenciesWithModel:(NSDictionary *) model;

-(void) injectDependenciesUsingInjectors:(NSArray *) dependencyInjectors;

-(void) instantiateUsingFactories:(NSArray *) objectFactories;

@end
