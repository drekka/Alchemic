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


NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Alchemic)

-(NSArray<id<ALCDependency>> *) methodArgumentsWithUnknownArgumentHandler:(void (^)(id argument)) unknownArgumentHandler;

-(id<ALCDependency>) modelSearchWithClass:(Class) dependencyClass;

-(id<ALCDependency>) dependencyWithClass:(Class) dependencyClass;

-(nullable ALCSimpleBlock) combineSimpleBlocks;

@end

NS_ASSUME_NONNULL_END

