//
//  ALCBuilderType.h
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import "ALCAbstractMethodBuilderType.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCMethodBuilderType : ALCAbstractMethodBuilderType

hideInitializer(initWithClassBuilder:(ALCBuilder *) classBuilder);

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder
                            selector:(SEL) selector
                          returnType:(Class) returnType;

@end

NS_ASSUME_NONNULL_END

