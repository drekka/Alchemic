//
//  ALCTypeData.h
//  Alchemic
//
//  Created by Derek Clarkson on 22/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCTypeData : NSObject
@property (nonatomic, strong, nullable) NSString *scalarType;
@property (nonatomic, assign, nullable) Class objcClass;
@property (nonatomic, strong, nullable) NSArray<Protocol *> *objcProtocols;
@end
