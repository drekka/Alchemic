//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

#import "ALCMethodBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilder

-(nonnull id) instantiateObject {
	STLog(self.valueClass, @"Getting a %s parent object for method", class_getName(self.parentClassBuilder.valueClass));
	id factoryObject = self.parentClassBuilder.value;
	return [self invokeMethodOn:factoryObject];
}

@end

NS_ASSUME_NONNULL_END
