//
//  ALCSingletonStorage.h
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCBuilderStorage.h"

/**
 Used when the object is a managed singleton.
 */
@interface ALCBuilderStorageSingleton : NSObject<ALCBuilderStorage>

@end
