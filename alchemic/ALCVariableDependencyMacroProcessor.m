//
//  ALCVariableDependencyMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCVariableDependencyMacroProcessor.h"
#import <Alchemic/Alchemic.h>
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCVariableDependencyMacroProcessor {
    NSString *_variableName;
}

-(instancetype) initWithParentClass:(Class) parentClass variable:(NSString *) variable {
    self = [super initWithParentClass:parentClass];
    if (self) {
        _variableName = variable;
    }
    return self;
}

-(void) validate {
    // Set the ivar.
    _variable = [ALCRuntime aClass:self.parentClass variableForInjectionPoint:_variableName];

    // Check macros
    if ([self.valueSourceMacros count] == 0) {
        [self.valueSourceMacros addObjectsFromArray:[ALCRuntime searchExpressionsForVariable:_variable].allObjects];
    }

    [super validate];
}

@end

NS_ASSUME_NONNULL_END
