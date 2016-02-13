//
//  ALCContextImpl.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCContextImpl.h"
#import "ALCModel.h"
#import "ALCModelImpl.h"
#import "ALCObjectFactory.h"
#import "ALCAbstractObjectFactory.h"
#import "ALCClassObjectFactory.h"

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
    [_model resolveDependencies];
    [_model startSingletons];
    STLog(self, @"\nRegistered model builders (* - instantiated):...\n%@\n", _model);
}

-(ALCClassObjectFactory *) registerClass:(Class) clazz {
    id<ALCObjectFactory> valueFactory = [[ALCClassObjectFactory alloc] initWithClass:clazz];
    [_model addObjectFactory:valueFactory withName:valueFactory.defaultName];
    return valueFactory;
}

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory changedName:(NSString *) oldName newName:(NSString *) newName {
    [_model objectFactory:objectFactory changedName:oldName newName:newName];
}

@end
