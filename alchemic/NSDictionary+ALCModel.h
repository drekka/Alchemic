//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 6/04/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ALCModel)

#pragma mark - Searching the model

-(NSDictionary *) objectDescriptionsWithClass:(Class) class;

-(NSDictionary *) objectDescriptionsWithProtocol:(Protocol *) protocol;

@end
