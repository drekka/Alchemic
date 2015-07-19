//
//  ACArg.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCArg.h"
#import "ALCInternalMacros.h"
#import "ALCMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCArg

+(instancetype) argWithType:(Class) argType, ... {

    ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] init];
    loadMacroProcessor(macroProcessor, argType);

    ALCArg *arg = [[ALCArg alloc] init];
    arg->_argType = argType;
    arg->_valueSource = [macroProcessor valueSource];

    return arg;
}

@end

NS_ASSUME_NONNULL_END
