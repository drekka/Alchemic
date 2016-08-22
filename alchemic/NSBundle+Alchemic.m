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

+(NSSet *) scannableBundles {

    // Start with the main app bundles.
    NSMutableSet<NSBundle *> *appBundles = [NSMutableSet setWithArray:[NSBundle allBundles]];

    // Get resource ids of the framework directories from each bundle
    NSMutableSet *mainBundleResourceIds = [[NSMutableSet alloc] init];
    [appBundles enumerateObjectsUsingBlock:^(NSBundle *bundle, BOOL *stop) {
        id bundleFrameworksDirId = nil;
        [bundle.privateFrameworksURL getResourceValue:&bundleFrameworksDirId forKey:NSURLFileResourceIdentifierKey error:nil];
        if (bundleFrameworksDirId) {
            [mainBundleResourceIds addObject:bundleFrameworksDirId];
        }
    }];

    // Loop through the app's frameworks and add those that are in the app bundle's frameworks directories.
    [[NSBundle allFrameworks] enumerateObjectsUsingBlock:^(NSBundle *framework, NSUInteger idx, BOOL *stop) {

        NSURL *frameworkDirectoryURL = nil;
        [framework.bundleURL getResourceValue:&frameworkDirectoryURL forKey:NSURLParentDirectoryURLKey error:nil];

        id frameworkDirectoryId = nil;
        [frameworkDirectoryURL getResourceValue:&frameworkDirectoryId forKey:NSURLFileResourceIdentifierKey error:nil];

        if ([mainBundleResourceIds containsObject:frameworkDirectoryId]) {
            [appBundles addObject:framework];
        }
    }];

    return appBundles;
}

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
