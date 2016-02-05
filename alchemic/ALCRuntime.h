//
//  ALCRuntime.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;

NS_ASSUME_NONNULL_BEGIN

@interface ALCRuntime : NSObject

/**
 Scans a class to find the actual variable used.
 @discussion The passed injection point is used to locate one of three possibilities.
 Either a matching instance variable with the same name, a class variable of the same name or a property whose variable uses the name. When looking for the variable behind a property, a '_' is prefixed.

 @param aClass the class to look at.
 @param inj   The name of the variable.

 @return the Ivar for the variable.
 @throw an exception if no matching variable is found.
 */
+(Ivar) aClass:(Class) aClass variableForInjectionPoint:(NSString *) inj;

@end

NS_ASSUME_NONNULL_END
