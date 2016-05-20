//
//  NSBundle+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <Alchemic/NSBundle+Alchemic.h>

#import <StoryTeller/StoryTeller.h>

#import <Alchemic/NSSet+Alchemic.h>
#import <Alchemic/ALCClassProcessor.h>

@implementation NSBundle (Alchemic)

-(NSSet<NSBundle *> *) scanWithProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context {
    
    STLog(self, @"Scanning bundle %@", self.bundlePath.lastPathComponent);
    unsigned int count = 0;
    const char** classes = objc_copyClassNamesForImage([[self executablePath] UTF8String], &count);
    
    NSMutableSet<NSBundle *> *moreBundles;
    for(unsigned int i = 0;i < count;i++) {
        Class nextClass = objc_getClass(classes[i]);
        for (id<ALCClassProcessor> classProcessor in processors) {
            if ([classProcessor canProcessClass:nextClass]) {
                NSSet<NSBundle *> *bundles = [classProcessor processClass:nextClass withContext:context];
                [NSSet unionSet:bundles intoMutableSet:&moreBundles];
            }
        }
    }
    
    return moreBundles;
}

@end
