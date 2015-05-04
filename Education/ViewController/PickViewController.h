//
//  PickViewController.h
//  Education
//
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

@end
