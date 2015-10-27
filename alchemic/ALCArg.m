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

+(instancetype) argWithType:(Class) argType macros:(id<ALCSourceMacro>) firstMacro, ... {

    NSMutableArray<id<ALCSourceMacro>> *properties = [NSMutableArray array];
    alc_processVarArgsIncluding(id<ALCSourceMacro>, firstMacro, ^(id<ALCSourceMacro> arg) {
        [properties addObject:arg];
    });

    return [self argWithType:argType properties:properties];
}

+(instancetype) argWithType:(Class) argType properties:(NSArray<id<ALCSourceMacro>> *) properties {
    ALCArg *newArg = [[ALCArg alloc] initWithType:argType];
    [properties enumerateObjectsUsingBlock:^(id<ALCSourceMacro> macro, NSUInteger idx, BOOL *stop) {
        [newArg addMacro:macro];
    }];
    return newArg;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"AcArg(%@, %@)", NSStringFromClass(self.valueType), [self.macros componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END
