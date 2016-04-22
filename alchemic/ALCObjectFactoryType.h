//
//  ALCObjectStorage.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectFactory.h"

@protocol ALCObjectFactoryType<NSObject>

@property (nonatomic, assign, readonly) ALCFactoryType factoryType;

@property (nonatomic, strong) id object;

@property (nonatomic, assign, readonly) BOOL ready;

@end
