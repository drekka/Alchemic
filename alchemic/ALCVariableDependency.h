//
//  ALCVariableDependency.h
//  alchemic
//
//  Created by Derek Clarkson on 26/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Alchemic/ALCDependency.h>
@import ObjectiveC;

NS_ASSUME_NONNULL_BEGIN

/**
 Class for dependencies which are variables in classes.
 */
@interface ALCVariableDependency : ALCDependency

@property (nonatomic, assign, readonly) Ivar variable;

-(instancetype) initWithValueClass:(Class) valueClass
							  valueSource:(id<ALCValueSource>) valueSource NS_UNAVAILABLE;

-(instancetype) initWithVariable:(Ivar) variable
                     valueSource:(id<ALCValueSource>) valueSource NS_DESIGNATED_INITIALIZER;

-(void) injectInto:(id) object;

@end

NS_ASSUME_NONNULL_END
