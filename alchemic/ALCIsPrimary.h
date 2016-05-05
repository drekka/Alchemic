//
//  ALCIsPrimary.h
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 When passed to a factory registration, sets the factory as a primary factory.

 @discussion This is mainly used for a couple of situations. Firstly where there are a number of candiates and you don't want to use names to define a default. Secondly during unit testing, this can be used to set registrations in unit test code as overrides to the app's instances.
 */
#define AcPrimary [ALCIsPrimary primaryMacro]

/**
 A simple macro that represents objects which are primary objects.
 */
@interface ALCIsPrimary : NSObject

/**
 Returns a singleton instance of the macro.

 @return A singleton instance.
 */
+ (instancetype) primaryMacro;
@end
