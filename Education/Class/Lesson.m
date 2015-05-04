//
//  Lesson.m
//  Education
//
//  Created by Feicun on 15/5/4.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "Lesson.h"

@implementation Lesson

- (id)initWithCloudLesson:(AVObject *)lesson {
    if (self = [super init]) {
        [self commonInit:lesson];
        AVQuery *tchQuery = [AVUser query];
        AVUser *tch = (AVUser *)[tchQuery getObjectWithId:[lesson objectForKey:@"teacher"]];
        self.teacher = [[User alloc] initWithAVUser:tch];
    }
    return self;
}

- (id)initWithCloudLesson:(AVObject *)lesson andTeacher:(User *)teacher {
    if (self = [super init]) {
        [self commonInit:lesson];
        self.teacher = teacher;
    }
    return self;
}

- (void)commonInit:(AVObject *)lesson {
    self.objectId = lesson.objectId;
    self.lessonType = [lesson objectForKey:@"lessonType"];
    self.startTime = [lesson objectForKey:@"startTime"];
    self.endTime = [lesson objectForKey:@"endTime"];
#warning 学生老师
    AVQuery *stuQuery = [AVUser query];
    [stuQuery whereKey:@"objectId" containedIn:[lesson objectForKey:@"students"]];
    NSArray *stuArr = [stuQuery findObjects];
    self.students = [[NSMutableArray alloc] init];
    for (AVObject *obj in stuArr) {
        [self.students addObject:[[User alloc] initWithAVUser:(AVUser *)obj]];
    }

}

- (void)uploadToCloud {
    AVObject *object = [AVObject objectWithClassName:@"Lesson"];
    [object setObject:self.lessonType forKey:@"lessonType"];
    [object setObject:self.startTime forKey:@"startTime"];
    [object setObject:self.endTime forKey:@"endTime"];
    NSMutableArray *stuArr = [[NSMutableArray alloc] init];
    for (User *stu in self.students) {
        [stuArr addObject:stu.objectId];
    }
    [object setObject:stuArr forKey:@"students"];
    [object setObject:self.teacher.objectId forKey:@"teacher"];
    [object saveInBackground];
}

@end
