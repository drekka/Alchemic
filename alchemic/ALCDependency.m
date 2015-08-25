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
#import "NSObject+ALCResolvable.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCDependency ()
@property (nonatomic, assign) BOOL available;
@end

@implementation ALCDependency

@synthesize available = _available;

-(void) dealloc {
    [self kvoRemoveWatchAvailable:_valueSource];
}

-(instancetype) initWithValueSource:(id<ALCValueSource>)valueSource {
    self = [super init];
    if (self) {
        _valueSource = valueSource;
        _available = valueSource.available;
        [self kvoWatchAvailable:_valueSource];
    }
    return self;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    [_valueSource resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    _available = _valueSource.available;
}

-(id) value {
    return _valueSource.value;
}

-(void) observeValueForKeyPath:(nullable NSString *) keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *,id> *) change
                       context:(nullable void *) context {
    // We are tracking the value source availability so indicate a change.
    STLog(self, @"Value source availability");
    self.available = _valueSource.available;
}

-(Class)valueClass {
    return _valueSource.valueClass;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"%@ -> %@", [ALCRuntime aClassDescription:_valueSource.valueClass], _valueSource];
}

@end

NS_ASSUME_NONNULL_END
