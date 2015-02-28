//
//  ALCAbstractInitialisationStrategy.h
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInitialisationStrategy.h"
#import "ALCInitialisationStrategyManagement.h"

@interface ALCAbstractInitialisationStrategy : NSObject<ALCInitialisationStrategy, ALCInitialisationStrategyManagement>

@end
