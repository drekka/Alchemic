//
//  ALCObjectStandIn.m
//  alchemic
//
//  Created by Derek Clarkson on 27/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCObjectProxy.h"
#import "ALCLogger.h"
#import "ALCClassInfo.h"
#import "ALCContext.h"

#import <objc/runtime.h>

@implementation ALCObjectProxy {
    ALCClassInfo *_classInfo;
    __weak ALCContext *_context;
}

-(instancetype) initWithFutureObjectInfo:(ALCClassInfo *) classInfo context:(__weak ALCContext *) context {
    logProxies(@"Creating proxy for %s", class_getName(classInfo.forClass));
    _classInfo = classInfo;
    _context = context;
    return self;
}

-(void) instantiate {
    if (_proxiedObject == nil) {
        logProxies(@"Asking context for a %s", class_getName(_classInfo.forClass));
        _proxiedObject = [_context objectForClassInfo:_classInfo];
        if (_proxiedObject == nil) {
            // A registered class that we don't know how to create.
            @throw [NSException exceptionWithName:@"AlchemicFailedToCreateSingleton"
                                           reason:[NSString stringWithFormat:@"Failed to create a instance of %s", class_getName(_classInfo.forClass)]
                                         userInfo:nil];
        }
        return;
    }
    logProxies(@"%s already instantiated", class_getName(_classInfo.forClass));
}

-(id) proxiedObject {
    if (_proxiedObject == nil) {
        [self instantiate];
    }
    return _proxiedObject;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (_proxiedObject == nil) {
        [self instantiate];
    }
    [invocation setTarget:_proxiedObject];
    [invocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_classInfo.forClass methodSignatureForSelector:sel];
}

-(NSString *) debugDescription {
    return [NSString stringWithFormat:@"Proxy for class %s", class_getName(_classInfo.forClass)];
}

@end
