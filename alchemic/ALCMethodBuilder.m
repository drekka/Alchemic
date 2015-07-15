//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCMethodBuilder.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import <Alchemic/Alchemic.h>

@implementation ALCMethodBuilder {
    ALCClassBuilder *_parentClassBuilder;
    SEL _selector;
    NSInvocation *_inv;
    NSMutableArray<ALCDependency *> *_invArgumentDependencies;
    BOOL _useClassMethod;

}

-(nonnull instancetype) initWithContext:(__weak ALCContext __nonnull *) context
                             valueClass:(Class __nonnull) valueClass
                                   name:(NSString __nonnull *)name
                     parentClassBuilder:(ALCClassBuilder __nonnull *) parentClassBuilder
                               selector:(SEL __nonnull) selector
                             qualifiers:(NSArray __nonnull *) qualifiers {

    self = [super initWithContext:context valueClass:valueClass name:name];
    if (self) {

        Class parentClass = parentClassBuilder.valueClass;

        // Locate the method.
        Method method = class_getInstanceMethod(parentClass, selector);
        if (method == NULL) {
            _useClassMethod = YES;
            method = class_getClassMethod(parentClass, selector);
        }

        // Validate the number of arguments.
        unsigned long nbrArgs = method_getNumberOfArguments(method) - 2;
        if (nbrArgs != [qualifiers count]) {
            @throw [NSException exceptionWithName:@"AlchemicIncorrectNumberArguments"
                                           reason:[NSString stringWithFormat:@"-[%s %s] - Expecting %lu argument matchers, got %lu",
                                                   class_getName(parentClass),
                                                   sel_getName(selector),
                                                   nbrArgs,
                                                   (unsigned long)[qualifiers count]]
                                         userInfo:nil];
        }

        _parentClassBuilder = parentClassBuilder;
        _selector = selector;
        _invArgumentDependencies = [[NSMutableArray alloc] init];

        // Setup the dependencies for each argument.
        //Class arrayClass = [NSArray class];
        [qualifiers enumerateObjectsUsingBlock:^(id qualifier, NSUInteger idx, BOOL *stop) {
            //NSSet<ALCQualifier *> *qualifierSet = [qualifier isKindOfClass:arrayClass] ? [NSSet setWithArray:qualifier] : [NSSet setWithObject:qualifier];
            // TODO
            //[self->_invArgumentDependencies addObject:[[ALCDependency alloc] initWithContext:context
            //                                                                      valueClass:[NSObject class]
            //                                                                      qualifiers:qualifierSet]];
        }];

    }
    return self;
}

-(nonnull id) instantiateObject {

    STLog(self.valueClass, @"Getting %s object", class_getName(_parentClassBuilder.valueClass));

    id factoryObject = _parentClassBuilder.value;

    // Get an invocation ready.
    if (_inv == nil) {
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
    STLog([self description], @"Created a %s", class_getName([returnObj class]));
    return returnObj;
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
    [_invArgumentDependencies enumerateObjectsUsingBlock:^(ALCDependency *dependency, NSUInteger idx, BOOL *stop) {
        [dependency resolveWithPostProcessors:postProcessors];
    }];
}

-(void) injectObjectDependencies:(id __nonnull) object {
    STLog([object class], @">>> Checking whether a %s instance has dependencies", object_getClassName(object));
    [self.context injectDependencies:object];
}

-(nonnull NSString *) description {
    return [NSString stringWithFormat:@"Method builder -[%s %s] for type %s", class_getName(_parentClassBuilder.valueClass), sel_getName(_selector), class_getName(self.valueClass)];
}

@end
