//
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 ALCWithName macros define a custom name for a object builder.
 */
@interface ALCFactoryName : NSObject

/**
 The name to be used for the factory.
 */
@property (nonatomic, strong, readonly) NSString *asName;

/**
 Default initializer.
 
 @param name	The name to use.
 
 @return An instance of ALCWithName.
 */
+(instancetype) withName:(NSString *) name;

@end
