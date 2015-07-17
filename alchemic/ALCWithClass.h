//
//  ALCWithClass.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCModelSearchExpression.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Wraps an argument so that it can be conveniantly passed around.
 */
@interface ALCWithClass : NSObject<ALCModelSearchExpression>

@property (nonatomic, assign, readonly) Class aClass;

+(instancetype) withClass:(Class) aClass;

-(BOOL) isEqualToWithClass:(ALCWithClass *) withClass;

@end

NS_ASSUME_NONNULL_END