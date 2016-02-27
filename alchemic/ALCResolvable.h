//
//  ALCResolvable.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCModel;
@protocol ALCResolvable;

NS_ASSUME_NONNULL_BEGIN

typedef void (^DependencyTraverseBlock)(id<ALCResolvable> resolvable, BOOL *stop);

@protocol ALCResolvable <NSObject>

@property (nonatomic, assign) BOOL enumeratingDependencies;

@property (nonatomic, assign, readonly) NSArray<id<ALCResolvable>> *dependencies;

-(void) enumerateDependenciesWithBlock:(DependencyTraverseBlock) block;

@end

NS_ASSUME_NONNULL_END

