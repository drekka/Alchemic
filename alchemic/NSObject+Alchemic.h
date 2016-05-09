//
//  NSObject+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 7/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCResolvable.h"

@protocol ALCDependency;
@protocol ALCModel;

@interface NSObject (Alchemic)

/**
 Executes the specified selector and returns the result.

 @param selector  The selector to execute.
 @param arguments The arguments required by the selector.

 */
-(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments;

/**
 Executes the specified selector and returns the result.

 @param selector  The selector to execute.
 @param arguments The arguments required by the selector.

 */
+(id) invokeSelector:(SEL) selector arguments:(NSArray<id<ALCDependency>> *) arguments;

-(void) resolveFactoryWithResolvingStack:(NSMutableArray<NSString *> *) resolvingStack
                            resolvedFlag:(BOOL *) resolvedFlag
                                   block:(void (^) (void)) block;

-(BOOL) dependenciesReady:(NSArray<id<ALCResolvable>> *) dependencies checkingStatusFlag:(BOOL *) checkingFlag;

@end
