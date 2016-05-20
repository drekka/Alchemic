//
//  ALCTypeDefs.h
//  alchemic
//
//  Created by Derek Clarkson on 20/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

/**
 Typedef for the simplest form of block. no args and no return.
 */
typedef void (^ALCSimpleBlock) (void);

/**
 Typedef for completion blocks.
 
 @param object The object that is completing.
 */
#define ALCObjectCompletionArgs id object
typedef void (^ALCObjectCompletion) (ALCObjectCompletionArgs);
