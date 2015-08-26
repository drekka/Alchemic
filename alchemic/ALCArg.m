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
#import "NSSet+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCArg

+(instancetype) argWithType:(Class) argType macros:(id<ALCMacro>) firstMacro, ... {
	ALCArg *newArg = [[ALCArg alloc] initWithType:argType];
	alc_processVarArgsIncluding(id<ALCMacro>, firstMacro, ^(id<ALCMacro> arg){[newArg addMacro:arg];});
	return newArg;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"AcArg(%@, %@)", NSStringFromClass(self.valueType), [self.macros componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END
