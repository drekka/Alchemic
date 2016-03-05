//
//  ALCAbstractObjectGenerator.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCObjectGenerator.h"

@protocol ALCModel;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectGenerator : NSObject<ALCObjectGenerator>

-(instancetype) init NS_UNAVAILABLE;

-(instancetype) initWithClass:(Class) objectClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

