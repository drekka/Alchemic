//
//  ALCCloudKeyvValueStoreAspect.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCResolveAspect.h>

/**
 Aspect which enables clould based key value storage access.
 
 @see https://developer.apple.com/library/prerelease/content/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForKey-ValueDataIniCloud.html
 
 If the user has not defined any class derived from ALCCloudKeyValueStore, this aspect will set ALCCloudKeyValueStore as the default object for handling cloud based data.
 
 Otherwise a class can be declared which extends ALCCloudKeyValueStore. All that needs to be added are properties. The parent ALCCloudKeyValueStore will take care of managing the synchronization with the cloud.
 */
@interface ALCCloudKeyValueStoreAspect : NSObject<ALCResolveAspect>

@end
