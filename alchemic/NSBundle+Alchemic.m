//
//  NSBundle+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "NSBundle+Alchemic.h"

#import <StoryTeller/StoryTeller.h>

#import "NSSet+Alchemic.h"
#import "ALCRuntimeScanner.h"

@implementation NSBundle (Alchemic)

-(NSSet<NSBundle *> *) scanWithScanners:(NSArray<ALCRuntimeScanner *> *) scanners {

    STLog(self, @"Scanning bundle %@", self.bundlePath.lastPathComponent);
    unsigned int count = 0;
    const char** classes = objc_copyClassNamesForImage([[self executablePath] UTF8String], &count);

    NSMutableSet<NSBundle *> *moreBundles;
    for(unsigned int i = 0;i < count;i++) {
        Class nextClass = objc_getClass(classes[i]);
        for (ALCRuntimeScanner *scanner in scanners) {
            [NSSet unionSet:[scanner scanClass:nextClass] intoMutableSet:&moreBundles];
        }
    }

    return moreBundles;
}

@end
