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
 Typedef for blocks which are passed a single object.
 
 @param object The object to be passed to the block.
 */
#define ALCBlockWithObjectArgs id object
typedef void (^ALCBlockWithObject) (ALCBlockWithObjectArgs);
