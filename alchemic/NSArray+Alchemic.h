//
//  NSArray+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCDefs.h"

@protocol ALCDependency;
@protocol ALCInjection;
@protocol ALCModel;
@protocol ALCResolvable;

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Alchemic)

-(NSArray<id<ALCDependency>> *) methodArgumentsWithUnknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler;

-(id<ALCInjection>) injectionWithClass:(Class) injectionClass allowConstants:(BOOL) allowConstants;

-(nullable ALCSimpleBlock) combineSimpleBlocks;

-(void)resolveArgumentsWithStack:(NSMutableArray<id<ALCResolvable>> *)resolvingStack model:(id<ALCModel>) model;

@end

NS_ASSUME_NONNULL_END

