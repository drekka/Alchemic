//
//  ALCBuilderPersonality.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
#import "ALCAbstractBuilderPersonality.h"
@class ALCValueSourceFactory;

NS_ASSUME_NONNULL_BEGIN

@interface ALCClassBuilderPersonality : ALCAbstractBuilderPersonality

-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory;

@end

NS_ASSUME_NONNULL_END
