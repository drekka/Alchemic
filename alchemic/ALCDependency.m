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
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCDependency

hideInitializerImpl(init)

-(instancetype) initWithValueSource:(id<ALCValueSource>) valueSource {
    self = [super init];
    if (self) {
        _valueSource = valueSource;
    }
    return self;
}

-(id) value {
    return _valueSource.value;
}

-(Class)valueClass {
    return _valueSource.valueClass;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@%@", _valueSource, self.valueSource.ready ? @" - instantiable" : @""];
}

@end

NS_ASSUME_NONNULL_END
