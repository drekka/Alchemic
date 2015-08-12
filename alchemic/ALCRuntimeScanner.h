//
//  ALCRuntimeScanner.h
//  Alchemic
//
//  Created by Derek Clarkson on 8/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCContext;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ClassSelector)(Class aClass);
typedef void(^ClassProcessor)(ALCContext *context, Class aClass);

/**
 Used to scan the runtime looking for Alchemic methods.
 
 @discussion These methods are then called to perform the various registration that build Alchemic's model of objects.
 */
@interface ALCRuntimeScanner : NSObject

/**
 A block which makes the descision as to whether a class should be processed for Alchemic related use.
 */
@property(nonatomic, copy, readonly) ClassSelector selector;

/**
 A block which processes the class. This could result in objects being created, the model being added to or other processes.
 */
@property(nonatomic, copy, readonly) ClassProcessor processor;

/**
 Default initalizer.

 @param selector  A block which defines which classes are to be processed.
 @param processor A block which contains the processing code.

 @return An instance of this class.
 */
-(instancetype) initWithSelector:(ClassSelector) selector
							  processor:(ClassProcessor) processor;

/**
 Factory method which returns a scanner which searches for Alchemic registration class methods.

 @return A scanner.
 */
+(instancetype) modelScanner;

/**
 Factory method which returns a scanner which searches for dependency post processors.

 @return A scanner.
 */
+(instancetype) dependencyPostProcessorScanner;

/**
 Factory method which returns a scanner which searches for resource locator classes.

 @return A scanner.
 */
+(instancetype) resourceLocatorScanner;

@end

NS_ASSUME_NONNULL_END
