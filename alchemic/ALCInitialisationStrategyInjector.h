//
//  AlchemicRuntimeInjector.h
//  alchemic
//
//  Created by Derek Clarkson on 17/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCInitialisationInjector.h"

/**
 This class handles self injection into the iOS runtime.
 */
@interface ALCInitialisationStrategyInjector : NSObject<ALCInitialisationInjector>

@end
