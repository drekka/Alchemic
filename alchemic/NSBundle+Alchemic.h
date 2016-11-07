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
@protocol ALCModel;

/**
 NSBundle extensions.
 */
@interface NSBundle (Alchemic)

/**
 Scans all the frameworks in the application using the passed ALCClassProcessor instances for Alchemic registrations.

 @param processors A list of processors to scan all classes with.
 @param context    The current context.
 */
+(void) scanApplicationWithProcessors:(NSArray<id<ALCClassProcessor>> *) processors context:(id<ALCContext>) context;

@end
