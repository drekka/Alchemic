//
//  ALCMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@protocol ALCMacroProcessor <NSObject>

-(void) addArgument:(id) argument;

/**
 Call after sending all arguments to validate the content sent.

 @param parentClass the class that the data is about.
 */
-(void) validate;

@end
