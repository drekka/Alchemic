//
//  NSBundle+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <Alchemic/NSBundle+Alchemic.h>

@import StoryTeller;

#import <Alchemic/NSSet+Alchemic.h>
#import <Alchemic/ALCClassProcessor.h>

@implementation NSBundle (Alchemic)

-(void) scanWithProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context {
    
    unsigned int count = 0;
    const char** classes = objc_copyClassNamesForImage([[self executablePath] UTF8String], &count);
    
    STLog(self, @"Scanning %i runtime classes in bundle %@", count, self.bundlePath.lastPathComponent);
    
    for(unsigned int i = 0;i < count;i++) {
        Class nextClass = objc_getClass(classes[i]);
        STLog(self, @"%@, class: %@", self.bundlePath.lastPathComponent, NSStringFromClass(nextClass));
        for (id<ALCClassProcessor> classProcessor in processors) {
            if ([classProcessor canProcessClass:nextClass]) {
                [classProcessor processClass:nextClass withContext:context];
            }
        }
    }
}

@end
