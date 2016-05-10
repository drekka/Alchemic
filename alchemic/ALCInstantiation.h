//
//  ALCInstantiationResult.h
//  Alchemic
//
//  Created by Derek Clarkson on 9/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

#import "ALCDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCInstantiation : NSObject

+(instancetype) instantiationWithObject:(id) object completion:(nullable ALCObjectCompletion) completion;

@property (nonatomic, strong, readonly) id object;

-(void) addCompletion:(nullable ALCObjectCompletion) newCompletion;

-(void) complete;



@end

NS_ASSUME_NONNULL_END
