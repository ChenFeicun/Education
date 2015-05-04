//
//  MonthView.h
//  Education
//
//  Created by Feicun on 15/4/19.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DayView.h"

@protocol MonthDayClick <NSObject>

- (void)clickMonthDay:(DayView *)dayView;

@end

@interface MonthView : NSView

//日历显示  第一格和最后一格日期
@property (strong, nonatomic) NSString *firstDate;
@property (strong, nonatomic) NSString *lastDate;
@property (strong, nonatomic) id<MonthDayClick> delegate;
@property (strong, nonatomic) NSDictionary *curDate;
@property (strong, nonatomic) NSMutableArray *allDay;

- (void)updateCalendarWithMonth:(int)month withYear:(int)year;

@end
