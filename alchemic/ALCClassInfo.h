//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependencyInfo;

@interface ALCClassInfo : NSObject

@property (nonatomic, assign, readonly) Class forClass;
@property (nonatomic, assign, readonly) NSString *name;
@property (nonatomic, assign, readonly) NSArray *protocols;
@property (nonatomic, assign) BOOL isSingleton;

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) forClass name:(NSString *) name;

-(void) addDependency:(ALCDependencyInfo *) dependency;

-(void) resolveDependenciesUsingResolvers:(NSArray *) objectResolvers;

@end
