//
//  ALCConstructorInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCDependency;

@interface ALCInstance : NSObject

@property (nonatomic, assign, readonly) Class forClass;
@property (nonatomic, strong) id finalObject;
@property (nonatomic, assign) BOOL instantiate;

#pragma mark - Life cycle

-(instancetype) initWithClass:(Class) class;

@end
