//
//  ALCInitializerBuilderPersonality.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCAbstractMethodBuilderPersonality.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCInitializerBuilderPersonality : ALCAbstractMethodBuilderPersonality

hideInitializer(initWithClassBuilder:(ALCBuilder *) classBuilder);

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder
                         initializer:(SEL) initializer;

@end

NS_ASSUME_NONNULL_END
