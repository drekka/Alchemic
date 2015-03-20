//
//  ALCObjectInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 18/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ALCObjectInjector <NSObject>

/**
 Looks at the candidates and decides which ones, if any should be injected.
 
 @param object     the object to inject.
 @param dependency the dependency info about what needs injecting.
 @param candidates an array of candidates.
 
 @return YES if an injection was performed.
 */
-(BOOL) inject:(id) object dependency:(ALCDependencyInfo *) dependency withCandidates:(NSArray *) candidates;

@end
