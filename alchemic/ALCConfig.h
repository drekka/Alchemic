//
//  ALCConfig.h
//  Alchemic
//
//  Created by Derek Clarkson on 8/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;

NS_ASSUME_NONNULL_BEGIN

/**
 Class which implement this protocol can configure Alchemic.
 */
@protocol ALCConfig <NSObject>

@optional

/**
 BY default Alchemic scans all app bundles and the Alchemic framework bundle. If you need to scan other frameworks or bundles then you can select them by choosing one of the classes in those bundles and returning it in this list. Alchemic will then add those bundles to the list of bundles to be scanned for DI definitions.
 
 @return a list of classes. Each class will be used to locate the corresponding bundle for scanning.
 */
+(nullable NSArray<Class> *) scanBundlesWithClasses;

+(void) configure:(id<ALCContext>) context;

@end

NS_ASSUME_NONNULL_END
