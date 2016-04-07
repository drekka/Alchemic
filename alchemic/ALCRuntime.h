//
//  ALCRuntime.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@class ALCTypeData;
@protocol ALCContext;

NS_ASSUME_NONNULL_BEGIN

@interface ALCRuntime : NSObject

+(Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

+(ALCTypeData *) typeDataForIVar:(Ivar) iVar;

+(void)setObject:(id) object variable:(Ivar) variable withValue:(id) value;

/**
 Validates that the passed selector occurs on the passed class and has a correct set of arguments stored in the macro processor.

 @param aClass The class to be used to check the selector again.
 @param selector The selector to check.
 @exception ALCException If there is a problem.
 */
+(void) validateClass:(Class) aClass selector:(SEL)selector;

+(NSString *) selectorDescription:(Class) aClass selector:(SEL)selector;

+(NSString *) propertyDescription:(Class) aClass property:(NSString *)property;

#pragma mark - Scanning

+(void) scanRuntimeWithContext:(id<ALCContext>) context;

@end

NS_ASSUME_NONNULL_END
