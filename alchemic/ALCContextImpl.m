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
#import "ALCClassObjectFactory.h"
#import "ALCMethodObjectFactory.h"
#import "ALCClassObjectFactoryInitializer.h"
#import "ALCDependency.h"

NS_ASSUME_NONNULL_BEGIN

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
    STLog(self, @"\n%@", _model);
}

-(ALCClassObjectFactory *) registerClass:(Class) clazz {
    ALCClassObjectFactory *objectFactory = [[ALCClassObjectFactory alloc] initWithClass:clazz];
    [_model addObjectFactory:objectFactory withName:objectFactory.defaultName];
    return objectFactory;
}

-(ALCMethodObjectFactory *) registerMethod:(SEL) selector
                       parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                                      args:(NSArray<id<ALCDependency>> *) arguments
                                returnType:(Class) returnType {
    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:(Class) returnType
                                                                      parentObjectFactory:parentObjectFactory
                                                                                 selector:selector
                                                                                     args:arguments];
    [_model addObjectFactory:methodFactory withName:methodFactory.defaultName];
    return methodFactory;
}

-(void) registerInitializer:(SEL) initializer
        parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                       args:(NSArray<id<ALCDependency>> *) arguments {
    ALCClassObjectFactoryInitializer *objectInitializer = [[ALCClassObjectFactoryInitializer alloc] initWithClass:parentObjectFactory.objectClass
                                                                                                      initializer:initializer
                                                                                                             args:arguments];
    parentObjectFactory.initializer = objectInitializer;
}

-(void) objectFactory:(id<ALCObjectFactory>) objectFactory
          changedName:(NSString *) oldName
              newName:(NSString *) newName {
    [_model objectFactory:objectFactory
              changedName:oldName
                  newName:newName];
}

@end

NS_ASSUME_NONNULL_END
