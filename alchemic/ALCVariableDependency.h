//
//  ALCDependencyRef.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import <Alchemic/ALCAbstractDependency.h>

@protocol ALCInjector;
@protocol ALCValueSource;
@class ALCType;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCDependency;

/**
 Implementation of the ALCDependency protocol which contains information for injecting a value into an object's variable or property.
 */
@interface ALCVariableDependency : ALCAbstractDependency

/// The name of the variable that will be injected.
@property (nonatomic, strong, readonly) NSString *name;

/**
 Unavailable initiailizer.
 @param injector -
 */
-(instancetype) initWithType:(ALCType *) type
                 valueSource:(id<ALCValueSource>) valueSource NS_UNAVAILABLE;

/**
 Factory method for creating instances of ALCVariableDependency.

 This is the only way these instances can be created.

 @param ivar      The variable to inject.
 @param name      The originally requested variable name. Used for logging and messages.

 @return An instance of ALCVariableDependency.
 */
+(instancetype) variableDependencyWithType:(ALCType *) type
                               valueSource:(id<ALCValueSource>) valueSource
                                  intoIvar:(Ivar) ivar
                                  withName:(NSString *) name;


@end

NS_ASSUME_NONNULL_END
