//
//  ALCInstantiationResult.h
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInternalMacros.h"

@interface ALCFactoryResult : NSObject

@property (nonatomic, strong, readonly) id object;
@property (nonatomic, assign, readonly) ALCSimpleBlock completion;

+(instancetype) resultWithObject:(id) object completion:(ALCSimpleBlock) completion;

@end
