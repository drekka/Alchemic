//
//  ALCModel.h
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCBuilder;
@class ALCClassBuilder;
@class ALCQualifier;

/**
 Core object management.
 */
@interface ALCModel : NSObject

@property (nonatomic, assign, readonly) NSUInteger numberBuilders;

/**
 Adds a builder to the model.

 @param builder	the builder to be added.
 */
-(void) addBuilder:(id<ALCBuilder> __nonnull) builder;

#pragma mark - Querying

-(nonnull NSSet<id<ALCBuilder>> *) allBuilders;

-(nonnull NSSet<ALCClassBuilder *> *) allClassBuilders;

/**
 Finds all builder which are matched by the passed list of qualifiers.
 
 @return a NSSet of builders that return objects of the class.
 */
-(nonnull NSSet<id<ALCBuilder>> *) buildersForQualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers;

-(nonnull NSSet<ALCClassBuilder *> *) classBuildersFromBuilders:(NSSet<id<ALCBuilder>> __nonnull *) builders;

@end
