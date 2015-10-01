//
//  ALCFactoryStorage.h
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilderStorage.h"

/**
 Storage used when deailing with factory builders.
 
 @discussion This is actually a "no-storage" option in that it does not actually store the object and will always return a nil.
 */
@interface ALCBuilderStorageFactory : NSObject<ALCBuilderStorage>

@end
