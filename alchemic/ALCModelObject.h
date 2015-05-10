//
//  ALCModelObject.h
//  alchemic
//
//  Created by Derek Clarkson on 8/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCObjectMetadata.h"

@class ALCContext;

@interface ALCModelObject : NSObject<ALCObjectMetadata>

@property(nonatomic, weak, readonly) ALCContext *context;

/**
 Initialiser used when registering classes.
 */
-(instancetype) initWithContext:(__weak ALCContext *) context objectClass:(Class) objectClass;

@end
