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

@property (nonatomic, assign) NSString *name; // Updatable.
@property (nonatomic, assign, readonly) Class forClass;
@property (nonatomic, assign, readonly) NSArray *protocols;

@property (nonatomic, strong) id finalObject;
@property (nonatomic, assign) BOOL createInstance; // If YES, instance will be created automatically.

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) forClass name:(NSString *) name;

-(void) addDependency:(ALCDependency *) dependency;

-(void) resolveDependenciesInModel:(NSDictionary *) model usingResolvers:(NSArray *) resolvers;

-(void) instantiateUsingFactories:(NSArray *) objectFactories;

-(void) injectDependenciesUsingInjectors:(NSArray *) injectors;

@end
