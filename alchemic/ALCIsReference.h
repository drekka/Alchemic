//
//  ALCIsExternal.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 When passed to a factory registration, sets the factory as storing and inject external objects.

 @discussion Can only be used on class factories as it makes no sense when set on method or initializers.
 */
#define AcReference [ALCIsReference referenceMacro]

/**
 Tag macro that indicates that the source of objects is external to Alchemic.
 */
@interface ALCIsReference : NSObject

/**
 Returns a singleton instance of the macro.

 @return A singleton instance.
 */
+ (instancetype) referenceMacro;

@end
