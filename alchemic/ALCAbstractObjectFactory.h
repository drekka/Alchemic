//
//  ALCAbstractObjectFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"
#import "ALCAbstractObjectGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectFactory : ALCAbstractObjectGenerator<ALCObjectFactory>

-(id) instantiateObject;

// Object factories must be settable.
@property (nonatomic, strong) id object;

@end

NS_ASSUME_NONNULL_END