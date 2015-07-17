//
//  ALCAbstractMacroProcessor.m
//  
//
//  Created by Derek Clarkson on 17/07/2015.
//
//

#import "ALCAbstractMacroProcessor.h"
#import "ALCConstantValue.h"
#import "ALCModelValueSource.h"
#import "ALCConstantValueSource.h"

@implementation ALCAbstractMacroProcessor

-(instancetype)initWithParentClass:(Class)parentClass {
    self = [super init];
    if (self) {
        _parentClass = parentClass;
    }
    return self;
}

-(void) addArgument:(id)argument {
    @throw [NSException exceptionWithName:@"AlchemicUnexpectedMacro"
                                   reason:[NSString stringWithFormat:@"Unexpected macro %@ for %@ class registration", argument, NSStringFromClass(self.parentClass)]
                                 userInfo:nil];
}

-(void) validate {
    [self doesNotRecognizeSelector:_cmd];
}

-(id<ALCValueSource>) valueSourceForMacros:(NSArray *) macros {
    if ([macros[0] isKindOfClass:[ALCConstantValue class]]) {
        return [[ALCConstantValueSource alloc] initWithValue:((ALCConstantValue *)macros[0]).value];
    }
    return [[ALCModelValueSource alloc] initWithSearchExpressions:[NSSet setWithArray:macros]];
}

@end
