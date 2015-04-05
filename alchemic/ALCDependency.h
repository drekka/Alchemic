//
//  ALCDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCInstance;
#import <objc/runtime.h>

/**
 Container object for information about an injection.
 */
@interface ALCDependency : NSObject

@property (nonatomic, assign, readonly) Ivar variable;

@property (nonatomic, strong) NSString *resolveUsingName;
@property (nonatomic, assign) Class resolveUsingClass;
@property (nonatomic, strong, readonly) NSArray *resolveUsingProtocols;

@property (nonatomic, strong, readonly) NSDictionary *candidateObjectDescriptions;

-(void) setNewResolvingQualifiers:(NSArray *) qualifiers;

-(instancetype) initWithVariable:(Ivar) variable;

-(void) resolveUsingResolvers:(NSArray *) resolvers;

-(void) injectObject:(id) finalObject usingInjectors:(NSArray *) injectors;

@end
