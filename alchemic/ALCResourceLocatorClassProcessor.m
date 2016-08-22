//
//  ALCResourceLocatorClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "ALCResourceLocatorClassProcessor.h"

@implementation ALCResourceLocatorClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return NO;
    //return [aClass conformsToProtocol:@protocol(ALCResourceLocator)];
}

-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context model:(id<ALCModel>) model {
    //ALCBuilder *classBuilder = [context.model createClassBuilderForClass:class inContext:context];
    //classBuilder.value = [[aClass alloc] init];
}

@end
