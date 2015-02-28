//
//  AlchemicRuntime.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCRuntime : NSObject

/**
 Scans the classes in the runtime, looking for Alchemic signatures and declarations.
 */
+(void) scanForMacros;

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.
 
 @param class the class to look at.
 @param inj   The name of the variable.
 
 @return the actual name of the variable.
 @throw an exception if no matching variable is found.
 */
+(NSString *) findVariableInClass:(Class) class forInjectionPoint:(const char *) inj;


@end
