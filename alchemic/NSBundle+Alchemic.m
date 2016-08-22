//
//  NSBundle+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "NSBundle+Alchemic.h"

@import StoryTeller;

#import "NSSet+Alchemic.h"
#import "ALCClassProcessor.h"

@implementation NSBundle (Alchemic)

-(void) scanWithProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context {
    
    unsigned int count = 0;
    const char** classes = objc_copyClassNamesForImage([[self executablePath] UTF8String], &count);
    
    STLog(self, @"Scanning %i runtime classes in bundle %@", count, self.bundlePath.lastPathComponent);
    
    for(unsigned int i = 0;i < count;i++) {
        Class nextClass = objc_getClass(classes[i]);
        for (id<ALCClassProcessor> classProcessor in processors) {
            if ([classProcessor canProcessClass:nextClass]) {
                [classProcessor processClass:nextClass withContext:context];
            }
        }
    }
}

@end
