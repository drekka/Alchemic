//
//  ALCPrimaryObjectPostProcessor.h
//  alchemic
//
//  Created by Derek Clarkson on 29/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCDependencyPostProcessor.h>

/**
 Post Processor that searches for ALCBuilders tagged as primaries.
 
 @discussion This post processor is called to process all candidate builders found for a dependency. It looks through the builders and if there is at least one ALCBuilder tagged as a primary, returns only the primaries. Otherwise it returns the original list.
 */
@interface ALCPrimaryObjectDependencyPostProcessor : NSObject<ALCDependencyPostProcessor>

@end
