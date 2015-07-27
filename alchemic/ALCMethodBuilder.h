//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractMethodBuilder.h"
#import "ALCSearchableBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCMethodBuilder : ALCAbstractMethodBuilder<ALCSearchableBuilder>

-(instancetype) initWithSelector:(nonnull SEL)selector NS_UNAVAILABLE;

-(instancetype) initWithSelector:(nonnull SEL)selector valueClass:(Class) valueClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
