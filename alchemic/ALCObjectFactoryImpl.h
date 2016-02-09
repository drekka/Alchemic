//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCObjectFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCObjectFactoryImpl : NSObject<ALCObjectFactory>

+(id<ALCObjectFactory>) NoFactoryInstance;

@end

NS_ASSUME_NONNULL_END