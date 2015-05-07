//
//  PickViewController.h
//  Education
//  老师 学生选择/查看页面
//  Created by Feicun on 15/4/27.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PickViewController : NSViewController

//传入时间段
@property (nonatomic) int startHour;//开始小时
@property (nonatomic) int endHour;//结束小时
@property (nonatomic) NSString *lessonType;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) User *selectUser;

//Edit Add Check
@property (strong, nonatomic) NSString *pageType;//页面是修改 添加 Or 查看
@property (strong, nonatomic) Lesson *pageLesson;//传入Lesson
@end
