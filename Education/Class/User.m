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
        self.realName = [user objectForKey:@"realName"];
        self.password = user.password;
        self.type = [user objectForKey:@"type"];
        AVFile *file = [user objectForKey:@"image"];//[AVFile fileWithURL:@"the-file-remote-url"];
        if (file) {
            [file getThumbnail:YES width:100 height:100 withBlock:^(NSImage *image, NSError *error) {
                if (image && !error) {
                    self.image = image;
                }
            }];
        } else {
            self.image = [NSImage imageNamed:@"default.jpg"];
        }
    }
    return self;
}

@end
