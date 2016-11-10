//
//  ALCValueStore.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/10/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "AlchemicAware.h"


/**
 Public interface for all value stores.
 
 Value stores are general purposes storage facilities which are added to the model to provides various services.
 */
@protocol ALCValueStore <AlchemicAware>

#pragma mark - Subscripting services

-(id) objectForKeyedSubscript:(NSString *) key;

-(void) setObject:(id) obj forKeyedSubscript:(NSString<NSCopying> *) key;

@end
