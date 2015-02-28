//
//  ALCReplacedInit.h
//  alchemic
//
//  Created by Derek Clarkson on 26/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.

//

@import Foundation;

@class ALCContext;

/**
 Storage for a replaced init method.
 @discussion Outlines where it came from and stores the original IMP.
 */
@interface ALCOriginalInitInfo : NSObject
@property (nonatomic, assign, readonly) Class originalClass;
@property (nonatomic, assign, readonly) SEL initSelector;
@property (nonatomic, assign, readonly) IMP initIMP;
@property (nonatomic, strong, readonly) ALCContext *context;


/**
 Default initialisaer.
 
 @param class        The class the init came from.
 @param initSelector The selector that defines the init.
 @param initIMP      The original IMP of the init.
 @param context      The context doing the injections.
 
 @return An instance of ALCOriginalInitInfo.
 */
-(instancetype) initWithOriginalClass:(Class) originalClass
                         initSelector:(SEL) initSelector
                              initIMP:(IMP) initIMP
                          withContext:(ALCContext *) context;

@end
