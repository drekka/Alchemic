//
//  NSBundle+Alchemic.m
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import <Alchemic/NSBundle+Alchemic.h>
#import <Alchemic/Alchemic.h>

@import StoryTeller;

#import <Alchemic/ALCClassProcessor.h>

@implementation NSBundle (Alchemic)

+(void) scanApplicationWithProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context {

    // We have to base on Core Foundation code here because NSBundle.allBundles actually returns incorrect results if we are running when attached to Xcode. The bundles it returns are correct for the app, but not necessarily the bundles that the app has loaded. The end result is that when we query the classes we get back zero results.
    CFArrayRef allBundles = CFBundleGetAllBundles();
    for (int i = 0;i < CFArrayGetCount(allBundles);i++) {

        CFBundleRef bundle = (CFBundleRef) CFArrayGetValueAtIndex(allBundles, i);

        // Ignore all Apple bundles as we know they won't have Alchemic registration code in them.
        NSString *bundleId = (NSString *) CFBundleGetIdentifier(bundle);
        if (!bundleId || [bundleId hasPrefix:@"com.apple"]) {
            return;
        }

        // Now get the executable from the bundle so we can scan it for classes.
        NSURL *executableURL = (NSURL *) CFBridgingRelease(CFBundleCopyExecutableURL(bundle));
        if (executableURL) {
            [self scanExecutable:executableURL.fileSystemRepresentation withProcessors:processors context:context];
        }
    }
}

+(void) scanExecutable:(const char *) executable withProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context {

    // Get the classes.
    unsigned int count = 0;
    const char** classes = objc_copyClassNamesForImage(executable, &count);
    if (count == 0) {
        return;
    }

    STLog(self, @"Scanning %i runtime classes in executable %s", count, executable);

    for(unsigned int i = 0;i < count;i++) {
        Class nextClass = objc_getClass(classes[i]);
        for (id<ALCClassProcessor> classProcessor in processors) {
            if ([classProcessor canProcessClass:nextClass]) {
                [classProcessor processClass:nextClass withContext:context];
            }
        }
    }
    
    free(classes);
}

@end
