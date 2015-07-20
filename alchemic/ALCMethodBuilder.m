//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>
#import <Alchemic/Alchemic.h>

#import "ALCMethodBuilder.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCMethodRegistrationMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilder {
    ALCClassBuilder *_parentClassBuilder;
    SEL _selector;
    NSInvocation *_inv;
    NSMutableArray<ALCDependency *> *_invArgumentDependencies;
    BOOL _useClassMethod;

}

-(nonnull instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
                                         arguments:(ALCMethodRegistrationMacroProcessor *) arguments {

    self = [super initWithValueClass:arguments.returnType name:arguments.asName];
    if (self) {
        _parentClassBuilder = parentClassBuilder;
        _selector = arguments.selector;
        _invArgumentDependencies = [[NSMutableArray alloc] init];

        // Setup the dependencies for each argument.
        for (ALCArg *arg in arguments.methodValueSources) {
            [self->_invArgumentDependencies addObject:[[ALCDependency alloc] initWithValueClass:arg.argType
                                                                                    valueSource:[arg valueSource]]];
        };
    }
    return self;
}

-(nonnull id) instantiateObject {

    STLog(self.valueClass, @"Getting %s object", class_getName(_parentClassBuilder.valueClass));

    id factoryObject = _parentClassBuilder.value;

    // Get an invocation ready.
    if (_inv == nil) {
        STLog(self.valueClass, @"Creating an invocation for %@", NSStringFromSelector(_selector));
        NSMethodSignature *sig = [factoryObject methodSignatureForSelector:_selector];
        _inv = [NSInvocation invocationWithMethodSignature:sig];
        _inv.selector = _selector;
        [_inv retainArguments];
    }

    // Load the arguments.
    [_invArgumentDependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
        id argumentValue = dependency.value;
        [self->_inv setArgument:&argumentValue atIndex:(NSInteger)idx];
    }];

    STLog(self.valueClass, @">>> Creating object with %@", [self description]);
    [_inv invokeWithTarget:factoryObject];

    id returnObj;
    [_inv getReturnValue:&returnObj];
    STLog(self.valueClass, @"Created a %s", class_getName([returnObj class]));
    return returnObj;
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
    for(ALCDependency *dependency in _invArgumentDependencies) {
        [dependency resolveWithPostProcessors:postProcessors];
    };
}

-(void) injectObjectDependencies:(id __nonnull) object {
    STLog([object class], @">>> Checking whether a %s instance has dependencies", object_getClassName(object));
    [[ALCAlchemic mainContext] injectDependencies:object];
}

-(nonnull NSString *) description {
    return [NSString stringWithFormat:@"Method builder -[%s %s] for type %s", class_getName(_parentClassBuilder.valueClass), sel_getName(_selector), class_getName(self.valueClass)];
}

@end

NS_ASSUME_NONNULL_END
