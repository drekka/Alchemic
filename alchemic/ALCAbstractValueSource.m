//
//  ALCAbstractValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractValueSource.h"

@implementation ALCAbstractValueSource

-(NSSet<id> * _Nonnull)values {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(id) valueForType:(Class) finalType {

	NSSet<id> *values = [self values];

	// If we can return an array then do so.
	if ((finalType == NULL && [values count] > 1)
		|| [finalType isKindOfClass:[NSArray class]]) {
		return values.allObjects;
	}

	// Not a possible array.
	if ([values count] == 1) {
		return values.anyObject;
	}

	// finally error.
	@throw [NSException exceptionWithName:@"AlchemicTooManyCandidates"
											 reason:[NSString stringWithFormat:@"Expecting 1 object, but found %lu", (unsigned long)[values count]]
										  userInfo:nil];
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> * _Nonnull)postProcessors{
	[self doesNotRecognizeSelector:_cmd];
}

@end
