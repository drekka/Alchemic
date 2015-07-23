//
//  ALCVariableDependencyMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependencyMacroProcessor.h"
#import "ALCValueSourceFactory.h"
#import "ALCRuntime.h"
#import "ALCMacro.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCVariableDependencyMacroProcessor {
    Ivar _variable;
}

-(nonnull instancetype)init {
	return nil;
}

-(instancetype) initWithVariable:(nonnull Ivar) variable {
    self = [super init];
    if (self) {
		 _variable = variable;
    }
    return self;
}

-(void)addMacro:(nonnull id<ALCMacro>)macro {
	// Error if we get arg macros.
	if ([macro isKindOfClass:[ALCValueSourceFactory class]]) {
		[self raiseUnexpectedMacroError:macro];
	} else {
		[super addMacro:macro];
	}
}

-(void) validate {

    // Check macros and create if necessary.
    if ([self valueSourceCount] == 0) {
		 NSSet<id<ALCModelSearchExpression>> *macros = [ALCRuntime searchExpressionsForVariable:_variable];
		 for (id<ALCModelSearchExpression> macro in macros) {
			 [self addMacro: (id<ALCMacro>)macro];
		 }
    }

    [super validate];
}

@end

NS_ASSUME_NONNULL_END
