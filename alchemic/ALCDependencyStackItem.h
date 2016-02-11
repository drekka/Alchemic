//
//  ALCDependencyStackItem.h
//  Alchemic
//
//  Created by Derek Clarkson on 10/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@protocol ALCObjectFactory;

@interface ALCDependencyStackItem : NSObject

@property (nonatomic, strong, readonly) id<ALCObjectFactory> objectFactory;

-(instancetype) initWithObjectFactory:(id<ALCObjectFactory>) objectFactory description:(NSString *) description;

@end
