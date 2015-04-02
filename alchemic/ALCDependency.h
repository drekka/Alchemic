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
@property (nonatomic, strong, readonly) NSString *variableQualifier;
@property (nonatomic, assign, readonly) Class variableClass;
@property (nonatomic, strong, readonly) NSString *variableTypeEncoding;
@property (nonatomic, strong, readonly) NSArray *variableProtocols;
@property (nonatomic, strong, readonly) NSDictionary *candidateObjectDescriptions;

-(instancetype) initWithVariable:(Ivar) variable qualifier:(NSString *) qualifier;

-(void) resolveUsingResolvers:(NSArray *) resolvers;

-(void) injectObject:(id) finalObject usingInjectors:(NSArray *) injectors;

@end
