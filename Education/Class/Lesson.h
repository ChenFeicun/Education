//
//  Lesson.h
//  Education
//
//  Created by Feicun on 15/5/4.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

#warning lessonType应该设计的有扩展性...
@interface Lesson : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (nonatomic) NSString *lessonType;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;
@property (strong, nonatomic) NSMutableArray *students;
@property (strong, nonatomic) User *teacher;

- (instancetype)initWithCloudLesson:(AVObject *)lesson;
- (id)initWithCloudLesson:(AVObject *)lesson andTeacher:(User *)teacher;
- (void)uploadToCloud;

@end
