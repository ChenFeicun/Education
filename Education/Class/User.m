//
//  User.m
//  Education
//
//  Created by Feicun on 15/5/3.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "User.h"

@implementation User

- (id)initWithAVUser:(AVUser *)user {
    if (self = [super init]) {
        self.objectId = user.objectId;
        self.username = user.username;
        self.password = user.password;
        self.type = [user objectForKey:@"type"];
    }
    return self;
}

@end
