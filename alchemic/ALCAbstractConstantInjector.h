//
//  ALCAbstractConstantValue.h
//  Alchemic
//
//  Created by Derek Clarkson on 5/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCConstant.h"
#import "ALCInjector.h"
#import "ALCTypeDefs.h"

/**
 Abstract parent class of all constant value injectors. 
 
 Defines all common code that does not change across constants. Also serves to tag constants by implementing the empty protocol ALCConstant.
 */
@interface ALCAbstractConstantInjector : NSObject<ALCConstant, ALCInjector>

@end
