//
//  ALCClassProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCContext;
@protocol ALCModel;

/**
 *  Protocol which defines classes which can process the runtime for registrations. Each processor is called in turn to process every class in the runtime.
 */
@protocol ALCClassProcessor <NSObject>

/**
 Indicates if the processor can be applied to the class.
 
 @param aClass The class to be checked.
 
 @return YES if the class should be processed.
 */
-(BOOL) canProcessClass:(Class) aClass;

/**
 Processes an individual class. 
 
 Override this method in subclasses to implement the particular processor's logic.
 
 @param aClass  The class to be processed.
 @param context A reference to the Alchemic context.
 
 */
-(void) processClass:(Class) aClass withContext:(id<ALCContext>) context;

@end
