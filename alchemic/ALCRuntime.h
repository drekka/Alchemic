//
//  ALCRuntime.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

#import "ALCDefs.h"

@class ALCTypeData;
@class ALCInstantiation;
@protocol ALCContext;
@protocol ALCDependency;

NS_ASSUME_NONNULL_BEGIN

@interface ALCRuntime : NSObject

#pragma mark - Querying the runtime

+(Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

+(ALCTypeData *) typeDataForIVar:(Ivar) iVar;

#pragma mark - Seting variables

+(void) setObject:(id) object
         variable:(Ivar) variable
        withValue:(id) value;

+(void) setInvocation:(NSInvocation *) inv
             argIndex:(int) idx
            withValue:(id) value
              ofClass:(Class) valueClass;

+(id) mapValue:(id) value toType:(Class) type;

#pragma mark - Validating

/**
 Validates that the passed selector occurs on the passed class and has a correct set of arguments stored in the macro processor.

 @param aClass The class to be used to check the selector again.
 @param selector The selector to check.
 @exception ALCException If there is a problem.
 */
+(void) validateClass:(Class) aClass selector:(SEL)selector arguments:(nullable NSArray<id<ALCDependency>> *) arguments;

#pragma mark - Describing things

+(NSString *) selectorDescription:(Class) aClass selector:(SEL)selector;

+(NSString *) propertyDescription:(Class) aClass property:(NSString *)property;

+(NSString *) propertyDescription:(Class) aClass variable:(Ivar) variable;

#pragma mark - Scanning

+(void) scanRuntimeWithContext:(id<ALCContext>) context;

+(void) executeSimpleBlock:(nullable ALCSimpleBlock) block;

+(void) executeCompletion:(nullable ALCObjectCompletion) completion withObject:(id) object;

@end

NS_ASSUME_NONNULL_END
