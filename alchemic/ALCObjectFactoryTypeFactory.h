//
//  ALCFactoryTypeFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 31/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactoryType.h"

/**
 @brief A ALCOBjectFactoryType which defines factories. ie. No object is ever stored, causing object factories to create a new instance each time an object is requested from them.
 */
@interface ALCObjectFactoryTypeFactory : NSObject<ALCObjectFactoryType>

@end
