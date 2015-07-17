//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@class ALCClassBuilder;
@class ALCMethodRegistrationMacroProcessor;

NS_ASSUME_NONNULL_BEGIN

@interface ALCMethodBuilder : ALCAbstractBuilder

-(nonnull instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
                               arguments:(ALCMethodRegistrationMacroProcessor *) arguments NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
