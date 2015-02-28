//
//  ALCInitWrapper.h
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

/**
 Classes that implement this protocol can be used to inject wrappers into a class.
 */
@protocol ALCInitialisationStrategy <NSObject>

/**
 Returns YES if this wrapper is applicable to the class.
 
 @param class the class to test.
 
 @return YES if the wrapper can be used.
 */
-(BOOL) canWrapInitInClass:(Class) class;

/**
 The selector of the method that will be injected into the class. THis method should exist in the implementation of this protocol.
 @discussion This selector must have the same signature as the init method it is replacing.
 */
@property (nonatomic, assign, readonly) SEL wrapperSelector;

/**
 The selector of the init method in the class being injected.
 */
@property (nonatomic, assign, readonly) SEL initSelector;

@end
