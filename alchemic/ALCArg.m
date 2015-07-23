//
//  ACArg.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArg.h"
#import "ALCInternalMacros.h"
#import "ALCModelValueSource.h"
#import "ALCConstantValueSource.h"
#import "ALCConstantValue.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCArg

-(instancetype) init {
	return nil;
}

+(instancetype) argWithType:(Class) argType macros:(id<ALCValueDefMacro>) firstMacro, ... {
	ALCArg *newArg = [[ALCArg alloc] initWithArgType:argType];
	processVarArgsIncluding(id<ALCValueDefMacro>, firstMacro, [newArg addMacro:arg]);
	return newArg;
}

-(instancetype) initWithArgType:(Class) argType {
	self = [super init];
	if (self) {
		_argType = argType;
	}
	return self;
}

@end

NS_ASSUME_NONNULL_END
