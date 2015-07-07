//
//  ALCRuntimeClassProcessor.h
//  alchemic
//
//  Created by Derek Clarkson on 1/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCContext;

@protocol ALCClassProcessor <NSObject>

/**
 Process the class.
 */
-(void) processClass:(Class) aClass withContext:(ALCContext *) context;

@end
