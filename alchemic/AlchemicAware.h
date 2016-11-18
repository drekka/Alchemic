//
//  ALCAware.h
//  alchemic
//
//  Created by Derek Clarkson on 17/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Implement this protocol if you need to be aware of Alchemics life cycle.
 */
@protocol AlchemicAware <NSObject>

@optional

/**
 If presentCalled after all dependencies have been resolved.

 This method will always be called on the main thread.

 @param variable The variable that was just injected.
 */
-(void) alchemicDidInjectVariable:(NSString *) variable;

/**
 Called after all dependencies have been resolved.

 This method will always be called on the main thread.
*/
-(void) alchemicDidInjectDependencies;

@end
