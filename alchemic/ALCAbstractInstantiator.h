//
//  ALCClassInstantiator.h
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCInstantiator.h"

/**
 Abstract strategory for building objects.
 */
@interface ALCAbstractInstantiator : NSObject<ALCInstantiator>

/**
 Call after resolving to get the when available call back executed.
 
 @discussion Note that this should only be called once as it clears the call back after calling it.
 */
-(void) nowAvailable;

@end
