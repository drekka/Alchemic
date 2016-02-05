//
//  ALCInstantiator.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCValueFactory;

@protocol ALCInstantiator <NSObject>

-(id) instantiateForFactory:(id<ALCValueFactory>) valueFactory;

@end
