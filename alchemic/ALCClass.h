//
//  ALCWithClass.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Defines a search expression for model objects based on a specific class.
 */
@interface ALCClass : NSObject<ALCModelSearchExpression>

/// The class to look for on model objects.
@property (nonatomic, assign, readonly) Class aClass;

/**
 Default initializer.
 
 @param aClass The class to look for.
 */
+(instancetype) withClass:(Class) aClass;

/**
 Tests the passed class to see if it matches the class desired.
 
 @param withClass The class to test. If it matches or is a decendant of aClass then YES is returned.
 */
-(BOOL) isEqualToClass:(ALCClass *) withClass;

@end

NS_ASSUME_NONNULL_END