//
//  ALCConfigClassProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import StoryTeller;

#import <Alchemic/ALCConfigClassProcessor.h>
#import <Alchemic/ALCConfig.h>

@implementation ALCConfigClassProcessor

-(BOOL) canProcessClass:(Class) aClass {
    return [aClass conformsToProtocol:@protocol(ALCConfig)];
}

-(NSSet<NSBundle *> *) processClass:(Class) aClass
                        withContext:(id<ALCContext>) context {
    
    STLog(self, @"Found config class %@", NSStringFromClass(aClass));

    if ([aClass respondsToSelector:@selector(configure:)]) {
        STLog(self, @"Executing configure method");
        [(Class<ALCConfig>)aClass configure:context];
    }

    if ([aClass respondsToSelector:@selector(scanBundlesWithClasses)]) {
        STLog(self, @"Reading list fo additional bundles");
        NSMutableSet<NSBundle *> *moreBundles;
        NSArray<Class> *configClasses = [((id<ALCConfig>)aClass) scanBundlesWithClasses];
        if (configClasses) {
            moreBundles = [[NSMutableSet alloc] initWithCapacity:configClasses.count];
            for (Class nextClass in [((id<ALCConfig>)aClass) scanBundlesWithClasses]) {
                [moreBundles addObject:[NSBundle bundleForClass:nextClass]];
            };
        }
        return moreBundles;
    }
    
    return nil;
}

@end
