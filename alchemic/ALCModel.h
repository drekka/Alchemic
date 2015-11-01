//
//  ALCModel.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCBuilder;
@protocol ALCModelSearchExpression;
@class ALCBuilder;

NS_ASSUME_NONNULL_BEGIN

/**
 Core object management.
 */
@interface ALCModel : NSObject

/**
 The total number of ALCBuilder instances in the model.
 
@discussion This does not include any ALCBuilder instances which are only accessible through ALCInitializerBuilder intances.
 */
@property (nonatomic, assign, readonly) NSUInteger numberBuilders;

/**
 Adds a builder to the model.

 @param builder	the builder to be added.
 */
-(void) addBuilder:(ALCBuilder *) builder;

/**
 Removes a builder form the model.
 
 @discussion This is usually done as part of putting an ALCInitializerBuilder in place as we don't want the ALCBuilder to be found when there is an initializer to be used.

 @param builder The builder to be removed.
 */
-(void) removeBuilder:(ALCBuilder *) builder;

-(void) builderDidChangeName:(NSString *) oldName newName:(NSString  *) newName;

#pragma mark - Querying

/**
 Returns a complete list of all the known ALCBuilder instances.

 @return A NSSet containing all the current builders.
 */
-(NSSet<ALCBuilder *> *) allBuilders;

/**
 Finds all builder which are matched by the passed NSSet of ALCModelSearchExpression
 
 @param searchExpressions A NSSet of search expressions which will be used to locate the builders.
 @return a NSSet of builders that return objects of the class.
 */
-(NSSet<ALCBuilder *> *) buildersForSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *) searchExpressions;

/**
 Filters a NSSet of ALCBuilder instances, return just the ALCBuilder instances.

 @param builders The original NSSet to filter.

 @return A new NSSet containing just builders which are class builder.
 */
-(NSSet<ALCBuilder *> *) classBuildersFromBuilders:(NSSet<ALCBuilder *> *) builders;

@end

NS_ASSUME_NONNULL_END
