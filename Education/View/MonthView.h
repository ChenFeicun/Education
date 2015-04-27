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

@property (strong, nonatomic) id<MonthDayClick> delegate;
@property (strong, nonatomic) NSDictionary *curDate;
- (void)updateCalendarWithMonth:(int)month withYear:(int)year;

@end
