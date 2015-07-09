//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractBuilder.h"

@class ALCClassBuilder;

@interface ALCMethodBuilder : ALCAbstractBuilder

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                                   name:(NSString __nonnull *)name
                     parentClassBuilder:(ALCClassBuilder __nonnull *) parentClassBuilder
                               selector:(SEL __nonnull) selector
                             qualifiers:(NSArray __nonnull *) qualifiers NS_DESIGNATED_INITIALIZER;

@end
