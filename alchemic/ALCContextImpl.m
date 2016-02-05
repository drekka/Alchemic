//
//  ALCContextImpl.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCContextImpl.h"
#import "ALCModel.h"
#import "ALCModelImpl.h"
#import "ALCValueFactory.h"
#import "ALCValueFactoryImpl.h"

@implementation ALCContextImpl {
    id<ALCModel> _model;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _model = [[ALCModelImpl alloc] init];
    }
    return self;
}

-(void) start {
    [self resolveDependencies];
}

- (void)resolveDependencies {
    for (id<ALCValueFactory> valueFactory in _model.valueFactories) {
        if (!valueFactory.resolved) {
            [valueFactory resolveWithStack:[NSMutableArray array] model:_model];
        }
    }
}

-(id<ALCValueFactory>) registerClass:(Class) clazz {
    id<ALCValueFactory> valueFactory = [[ALCValueFactoryImpl alloc] initWithClass:clazz];
    [_model addValueFactory:valueFactory withName:valueFactory.defaultName];
    return valueFactory;
}

@end
