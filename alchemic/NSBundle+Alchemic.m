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

    CFBundleRef mainBundle = CFBundleGetMainBundle();

    // first scan the app bundle.
    [self scanBundle:mainBundle withProcessors:processors context:context];
    //    CFURLRef homeDir = CFBundleCopyBundleURL(mainBundle);
    //    CFAutorelease(homeDir);
    //    [self scanDirectoryForBundles:homeDir withProcessors:processors context:context];

    CFURLRef frameworksDir = CFBundleCopyPrivateFrameworksURL(mainBundle);
    CFAutorelease(frameworksDir);
    [self scanDirectoryForFrameworks:frameworksDir withProcessors:processors context:context];
}

+(void) scanDirectoryForFrameworks:(CFURLRef) directory
                    withProcessors:(NSArray<id<ALCClassProcessor>> *) processors
                           context:(id<ALCContext>) context {
    CFArrayRef bundles = CFBundleCreateBundlesFromDirectory(NULL, directory, (CFStringRef) @"framework");
    CFAutorelease(bundles);

    for (int i = 0; i < CFArrayGetCount(bundles); i++) {
        CFBundleRef bundle = (CFBundleRef) CFArrayGetValueAtIndex(bundles, i);
        [self scanBundle:bundle withProcessors:processors context:context];
    }
}


+(void) scanBundle:(CFBundleRef) bundle
    withProcessors:(NSArray<id<ALCClassProcessor>> *) processors
           context:(id<ALCContext>) context {

    // Get the path to the executable in the bundle. Note that on devices this path is not entirely correct.
    CFURLRef executableURL = CFBundleCopyExecutableURL(bundle);

    // find out if we are dealing with a framework.
    CFURLRef bundleURL = CFBundleCopyBundleURL(bundle);
    CFStringRef extension = CFURLCopyPathExtension(bundleURL);
    CFRelease(bundleURL);

    const char *executableFilepath;
    if ([@"framework" isEqualToString:(__bridge NSString *) extension]) {
        // Get a file reference from the executable URL, then convert to a system path. This process of going through a file reference corrects the incorrect executable path returned on a device.
        CFURLRef executableFileRefereceURL = CFURLCreateFileReferenceURL(NULL, executableURL, NULL);
        CFStringRef executableFileReference = CFURLCopyFileSystemPath(executableFileRefereceURL, kCFURLPOSIXPathStyle);
        executableFilepath = CFStringGetCStringPtr(executableFileReference, kCFStringEncodingUTF8);
        CFRelease(executableFileRefereceURL);
        CFRelease(executableFileReference);
    } else {
        // Otherwise we can use the bundles executable path.
        CFStringRef executableFileSystemPath = CFURLCopyFileSystemPath(executableURL, kCFURLPOSIXPathStyle);
        executableFilepath = CFStringGetCStringPtr(executableFileSystemPath, kCFStringEncodingUTF8);
        CFRelease(executableFileSystemPath);
    }

    CFRelease(extension);
    CFRelease(executableURL);

    // Now get the number of classes.
    unsigned int count = 0;
    const char** classes = objc_copyClassNamesForImage(executableFilepath, &count);
    if (count == 0) {
        return;
    }

    STLog(self, @"Scanning %i runtime classes in bundle %@", count, bundle);
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
