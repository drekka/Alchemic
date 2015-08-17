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
 An extension of ALCDependency that can inject the result value into a variable in an object.

 @discussion This class is used by the `AcInject(...)` macro.
 */
@interface ALCVariableDependency : ALCDependency

/**
 The IVar that will be injected into.
 */
@property (nonatomic, assign, readonly) Ivar variable;

/**
 Default initializer.

 @param variable    An Ivar to be injected.
 @param valueSource The value source that will supply the values to be injected.

 @return An instance of this class.
 */
-(instancetype) initWithVariable:(Ivar) variable
                     valueSource:(id<ALCValueSource>) valueSource NS_DESIGNATED_INITIALIZER;

/**
 Perform the injection.

 @param object An object of a suitable type. This is assumed to have the correct Ivar.
 */
-(void) injectInto:(id) object;

@end

NS_ASSUME_NONNULL_END
