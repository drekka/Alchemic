//
//  ALCContext+Internal.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/Alchemic.h>

typedef void (^ProcessBuilderBlock)(NSSet<id<ALCBuilder>> __nonnull *);

/**
 Category which gives access to methods reserved for internal Alchemic processing.
 */

@interface ALCContext (Internal)

#pragma mark - Working with builders

-(void) addBuilderToModel:(id<ALCBuilder> __nonnull) builder;

-(void) executeOnBuildersWithQualifiers:(NSSet<ALCQualifier *> __nonnull *) qualifiers
                processingBuildersBlock:(ProcessBuilderBlock __nonnull) processBuildersBlock;

-(nonnull id) instantiateObjectFromBuilder:(id<ALCBuilder> __nonnull) builder;

-(nonnull NSSet<id<ALCBuilder>> *) postProcessCandidateBuilders:(NSSet<id<ALCBuilder>> __nonnull *) builders;

#pragma mark - Resolving

/**
 This needs to get rolled into the post processing or visa versa.

 //TODO refactor.

 @param dependency	<#dependency description#>
 @param candidates	<#candidates description#>

 @return <#return value description#>
 */
-(nonnull id) resolveValueForDependency:(ALCDependency __nonnull *) dependency candidates:(NSSet<id<ALCBuilder>> __nonnull *)candidates;

#pragma mark - Registration call backs

-(void) registerDependencyInClassBuilder:(ALCClassBuilder __nonnull *) classBuilder, ...;

-(void) registerClassBuilder:(ALCClassBuilder __nonnull *) classBuilder, ...;

-(void) registerObject:(id __nonnull) object withName:(NSString __nonnull *) name;

@end
