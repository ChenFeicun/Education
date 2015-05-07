//
//  User.h
//  Education
//
//  Created by Feicun on 15/5/3.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *realName;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSImage *image;

//特殊需要
@property (nonatomic) BOOL isSelected;

- (id)initWithAVUser:(AVUser *)user;

@end
