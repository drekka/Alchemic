//
//  alchemic
//
//  Created by Derek Clarkson on 17/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <StoryTeller/StoryTeller.h>

#import "ALCValueSource.h"
#import "ALCDependency.h"
#import "ALCDependencyPostProcessor.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCDependency

@synthesize resolved = _resolved;

-(instancetype) initWithValueSource:(id<ALCValueSource>)valueSource {
    self = [super init];
    if (self) {
        _valueSource = valueSource;
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
	_resolved = YES;
    [_valueSource resolveWithPostProcessors:postProcessors];
}

-(void) validateWithDependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {
	[_valueSource validateWithDependencyStack:dependencyStack];
}

-(id) value {
    return _valueSource.value;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"type %@ from: %@", [ALCRuntime aClassDescription:_valueSource.valueClass], _valueSource];
}

@end

NS_ASSUME_NONNULL_END
