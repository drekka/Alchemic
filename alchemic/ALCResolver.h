//
//  ALCResolver.h
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALCResolver : NSObject

@property (nonatomic, strong, readonly) NSArray *candidateInstances;
@property (nonatomic, strong) NSArray *dependencyMatchers;

-(instancetype) initWithMatchers:(NSArray *) dependencyMatchers;

-(void) resolveUsingModel:(NSDictionary *) model;

-(void) postProcess:(NSArray *) postProcessors;

@end
