//
//  NSBundle+Alchemic.h
//  Alchemic
//
//  Created by Derek Clarkson on 6/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCClassProcessor;
@protocol ALCContext;

/**
 NSBundle extensions.
 */
@interface NSBundle (Alchemic)

/**
 Scans a bundle with a variety of ALCClassProcessor instances for Alchemic registrations.
 
 @param processors A list of processors to scan all classes with.
 @param context    The current context.
 
 @return nil or a list of additonal NSBundles that may contain further registrations.
 */
-(NSSet<NSBundle *> *) scanWithProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context;

@end
