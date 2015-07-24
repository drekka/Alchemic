//
//  ACArg.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCValueSourceFactory.h"
#import "ALCInternalMacros.h"
#import "ALCModelValueSource.h"
#import "ALCConstantValueSource.h"
#import "ALCConstantValue.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCValueSourceFactory

-(instancetype) init {
	self = [super init];
	if (self) {
		_macros = [[NSMutableSet alloc] init];
	}
	return self;
}

-(nonnull id<ALCValueSource>) valueSource {
	id macro =_macros.anyObject;
	if ([macro isKindOfClass:[ALCConstantValue class]]) {
		return [[ALCConstantValueSource alloc] initWithValue:((ALCConstantValue *)macro).value];
	}
	return [[ALCModelValueSource alloc] initWithSearchExpressions:(NSSet<id<ALCModelSearchExpression>> *)_macros];
}

-(void) addMacro:(id<ALCValueDefMacro>) macro {
	[(NSMutableSet *)_macros addObject:macro];
}

-(void) validate {
	// If any argument is a constant then it must be the only one.
	for (id<ALCValueDefMacro> macro in _macros) {
		if ([macro isKindOfClass:[ALCConstantValue class]] && [_macros count] > 1) {
			@throw [NSException exceptionWithName:@"AlchemicInvalidArguments"
													 reason:[NSString stringWithFormat:@"AcValue(...) must be the only macro"]
												  userInfo:nil];
		}
	}
}

@end

NS_ASSUME_NONNULL_END
