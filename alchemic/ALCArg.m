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

@implementation ALCArg {
    ALCMacroProcessor *_macroProcessor;
}

+(instancetype) argWithType:(Class) argType expressions:(id) firstExpression, ... {

    ALCMacroProcessor *macroProcessor = [[ALCMacroProcessor alloc] init];
    loadMacrosIncluding(macroProcessor, firstExpression);

    ALCArg *arg = [[ALCArg alloc] init];
    arg->_argType = argType;
    arg->_macroProcessor = macroProcessor;

    return arg;
}

-(nonnull id<ALCValueSource>)valueSource {
    return [_macroProcessor valueSource];
}

@end

NS_ASSUME_NONNULL_END
