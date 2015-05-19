//
//  AlchemicRuntime.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

@class ALCResolvableObject;
@class ALCContext;

@interface ALCRuntime : NSObject

#pragma mark - General

+(const char *) concat:(const char *) left to:(const char *) right;

+(SEL) alchemicSelectorForSelector:(SEL) selector;

+(Ivar) class:(Class) class withName:(NSString *) name;

+(BOOL) classIsProtocol:(Class) possiblePrototocol;

+(void) validateMatcher:(id) object;

+(void) validateSelector:(SEL) selector withClass:(Class) class;

+(void) injectObject:(id) object variable:(Ivar) variable withValue:(id) value;

+(BOOL) class:(Class) class isKindOfClass:(Class) otherClass;

#pragma mark - Alchemic

/**
 Scans the classes in the runtime, looking for Alchemic signatures and declarations.
 @discussion Once found, the block is called to finish the registration of the class.
 */
+(void) scanRuntimeWithContext:(ALCContext *) context;

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.
 
 @param class the class to look at.
 @param inj   The name of the variable.
 
 @return the Ivar for the variable.
 @throw an exception if no matching variable is found.
 */
+(Ivar) class:(Class) class variableForInjectionPoint:(NSString *) inj;

@end
