//
//  ALCModel.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCBuilder;
@protocol ALCModelSearchExpression;
@class ALCClassBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 Core object management.
 */
@interface ALCModel : NSObject

@property (nonatomic, assign, readonly) NSUInteger numberBuilders;

/**
 Adds a builder to the model.

 @param builder	the builder to be added.
 */
-(void) addBuilder:(id<ALCBuilder>) builder;

-(void) removeBuilder:(id<ALCBuilder>) builder;

#pragma mark - Querying

-(NSSet<id<ALCBuilder>> *) allBuilders;

-(NSSet<ALCClassBuilder *> *) allClassBuilders;

/**
 Finds all builder which are matched by the passed list of qualifiers.
 
 @return a NSSet of builders that return objects of the class.
 */
-(NSSet<id<ALCBuilder>> *) buildersForSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions;

-(NSSet<ALCClassBuilder *> *) classBuildersFromBuilders:(NSSet<id<ALCBuilder>> *) builders;

@end

NS_ASSUME_NONNULL_END
