//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependency;

@interface ALCObjectDescription : NSObject

@property (nonatomic, assign, readonly) Class forClass;
@property (nonatomic, assign, readonly) NSString *name;
@property (nonatomic, assign, readonly) NSArray *protocols;
@property (nonatomic, strong, readonly) id finalObject;

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) forClass name:(NSString *) name;

-(void) addDependency:(ALCDependency *) dependency;

-(void) resolveDependenciesUsingResolvers:(NSArray *) objectResolvers;

-(void) instantiateUsingFactories:(NSArray *) objectFactories;

-(void) injectDependenciesUsingInjectors:(NSArray *) injectors;

@end
