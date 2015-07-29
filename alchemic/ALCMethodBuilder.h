//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractMethodBuilder.h"
#import "ALCSearchableBuilder.h"
@class ALCClassBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface ALCMethodBuilder : ALCAbstractMethodBuilder<ALCSearchableBuilder>

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
											 selector:(SEL) selector NS_UNAVAILABLE;

-(instancetype) initWithParentBuilder:(ALCClassBuilder *) parentClassBuilder
									  selector:(nonnull SEL)selector
									valueClass:(Class) valueClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
