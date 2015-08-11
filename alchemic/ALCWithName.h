//
//  ALCAsName.h
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCMacro.h"
/**
 ALCWithName macros define names that will be associated with an ALCBuilder.
 */
@interface ALCWithName : NSObject<ALCMacro>

/**
 The name to be used for the builder.
 */
@property (nonatomic, strong, readonly) NSString *asName;

/**
 Default initializer.

 @param name	The name to use.

 @return An instance of ALCWithName.
 */
+(instancetype) withName:(NSString *) name;

@end
