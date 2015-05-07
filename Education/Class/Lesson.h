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
- (void)deleteFromCloud;
//获取所有学生objectId
- (NSMutableArray *)getStudentsIdOfLesson;
//课程修改后更新呢
- (void)updateLesson:(Lesson *)newLesson;
//获取开始结束的小时
- (int)lessonStartHour;
- (int)lessonEndHour;
//某个学生是否有这门课
- (BOOL)isLessonContainsStudent:(User *)stu;
//删除掉某个学生
- (void)lessonRemoveStudent:(User *)stu;

@end
