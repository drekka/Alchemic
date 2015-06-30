//
//  ALCInitWrapper.h
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@class ALCInitDetails;
@class ALCClassBuilder;

/**
 Classes that implement this protocol can be used to inject wrappers into a class.
 */
@protocol ALCInitStrategy <NSObject>

+(BOOL) canWrapInit:(ALCClassBuilder *) classBuilder;

-(instancetype) initWithClassBuilder:(ALCClassBuilder *) classBuilder;

@end