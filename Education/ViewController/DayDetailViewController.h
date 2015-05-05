//
//  DayDetailViewController.h
//  Education
//
//  Created by Feicun on 15/4/21.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DayView.h"

@interface DayDetailViewController : NSViewController

@property (strong, nonatomic) NSDictionary *dateDict; //上个页面传递来的 Day信息
@property (nonatomic) BOOL isEditable;//页面信息是否可编辑 根据日期来
@property (strong, nonatomic) User *teacher;

@end
