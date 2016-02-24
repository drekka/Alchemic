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
#import "ALCMethodObjectFactory.h"

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
    id<ALCObjectFactory> valueFactory = [[ALCClassObjectFactory alloc] initWithClass:clazz];
    [_model addObjectFactory:valueFactory withName:valueFactory.defaultName];
    return valueFactory;
}

-(ALCMethodObjectFactory *) registerMethod:(SEL) selector
                       parentObjectFactory:(ALCClassObjectFactory *) parentObjectFactory
                                      args:(nullable NSArray<id<ALCDependency>> *) arguments
                                returnType:(Class) returnType {
    ALCMethodObjectFactory *methodFactory = [[ALCMethodObjectFactory alloc] initWithClass:(Class) returnType
                                                                      parentObjectFactory:parentObjectFactory
                                                                                 selector:selector
                                                                                     args:arguments];
    [_model addObjectFactory:methodFactory withName:methodFactory.defaultName];
    return methodFactory;
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
