//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCObjectFactory.h"

@interface ALCAbstractObjectFactory : NSObject<ALCObjectFactory>

+(id<ALCObjectFactory>) NoFactoryInstance;

@end
