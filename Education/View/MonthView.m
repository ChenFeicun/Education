//
//  MonthView.m
//  Education
//
//  Created by Feicun on 15/4/19.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import "MonthView.h"

@interface MonthView() <DayClick>

@end

@implementation MonthView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (id)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.allDay = [[NSMutableArray alloc] init];
    self.curDate = [self getCurrentMonthDayYear];
    [self updateCalendarWithMonth:[[self.curDate objectForKey:@"Month"] intValue] withYear:[[self.curDate objectForKey:@"Year"] intValue]];
}

- (BOOL)isToday:(int)day month:(int)month year:(int)year {
    if (day == [[self.curDate objectForKey:@"Day"] intValue] && month == [[self.curDate objectForKey:@"Month"] intValue] && year == [[self.curDate objectForKey:@"Year"] intValue]) {
        return YES;
    }
    
    return NO;
}

- (void)updateCalendarWithMonth:(int)month withYear:(int)year {
    //当前月
//    for (int i = 0; i < self.allDay.count; i++) {
//        [self.allDay[i] removeFromSuperview];
//    }
    [self.allDay removeAllObjects];
    int firstDay = [self getWeekdayWithMonth:month withDay:1 withYear:year];
    int monthLength = [self getMonthLength:month withYear:year];
    for (int day = 1, weekday = firstDay, i = 5; day <= monthLength && i >= 0; i--) {
        for (; weekday <= 7 && day <= monthLength; weekday++, day++) {
            NSString *dayText = @"";
            if (day == 1) {
                dayText = [NSString stringWithFormat:@"%i月%i日", month, day];
                self.firstDate = [NSString stringWithFormat:@"%i-%02i-01", year, month];
            } else {
                dayText = [NSString stringWithFormat:@"%i日", day];
                if (day == monthLength) {
                    self.lastDate = [NSString stringWithFormat:@"%i-%02i-%02i", year, month, monthLength];
                }
            }
            DayView *dayView = [[DayView alloc] initWithFrame:NSMakeRect(DAY_WIDTH * (weekday - 1) - (weekday - 1), i * DAY_HEIGHT - i, DAY_WIDTH, DAY_HEIGHT) andDayText:dayText andMonth:month andYear:year];
            dayView.state = 0;
            dayView.day = day;
            dayView.delegate = self;
            if ([self isToday:day month:month year:year]) {
                [dayView addCircleToCurDate:day];
            }
            [self.allDay addObject:dayView];
            //NSLog(@"%i", day);
        }
        weekday = 1;
    }
    //上个月
    int previous = 0;
    if (month - 1 <= 0) {
        //上年最后一个月
        previous = [self getMonthLength:12 withYear:year - 1] - firstDay + 2;
    } else {
        previous = [self getMonthLength:month - 1 withYear:year] - firstDay + 2;
    }
    
    for (int i = 0; i < firstDay - 1; i++, previous++) {
        int preMonth = month;
        int preYear = year;
        if (month == 1 && i == 0) {
            preMonth = 12;
            preYear = year - 1;
            self.firstDate = [NSString stringWithFormat:@"%i-12-%02i", preYear, previous];
        } else if (month != 1 && i == 0) {
            preMonth = month - 1;
            self.firstDate = [NSString stringWithFormat:@"%i-%02i-%02i", year, preMonth, previous];
        }
        NSString *dayText = [NSString stringWithFormat:@"%i日", previous];
        DayView *dayView = [[DayView alloc] initWithFrame:NSMakeRect(DAY_WIDTH * i - i, DAY_HEIGHT * 5 - 5, DAY_WIDTH, DAY_HEIGHT) andDayText:dayText andMonth:preMonth andYear:preYear];
        dayView.state = -1;
        dayView.day = previous;
        dayView.alphaValue = 0.3;
        dayView.delegate = self;
        [self.allDay addObject:dayView];
    }
    //下个月
    int leastDays = monthLength - (8 - firstDay);
    for(int i = 4 - leastDays / 7, count = 1, j = leastDays % 7; i >= 0; i--){
        for(; j < 7; j++, count++){
            int nextMonth = month;
            int nextYear = year;
            NSString *dayText = @"";
            if (count == 1) {
                if (month == 12) {
                    nextMonth = 1;
                    nextYear = year + 1;
                    dayText = [NSString stringWithFormat:@"1月%i日", count];
                } else {
                    nextMonth = month + 1;
                    dayText = [NSString stringWithFormat:@"%i月%i日", month + 1, count];
                }
            } else {
                nextMonth = month + 1;
                dayText = [NSString stringWithFormat:@"%i日", count];
            }
            DayView *dayView = [[DayView alloc] initWithFrame:NSMakeRect(DAY_WIDTH * j - j, DAY_HEIGHT * i - i, DAY_WIDTH, DAY_HEIGHT) andDayText:dayText andMonth:nextMonth andYear:nextYear];
            dayView.state = 1;
            dayView.day = count;
            dayView.alphaValue = 0.3;
            dayView.delegate = self;
            [self.allDay addObject:dayView];
        }
        j = 0;
    }
    if (35 - leastDays != 0) {
        if (month == 12) {
            self.lastDate = [NSString stringWithFormat:@"%i-01-%02i", year + 1, 35 - leastDays];
        } else {
            self.lastDate = [NSString stringWithFormat:@"%i-%02i-%02i", year, month + 1, 35 - leastDays];
        }
        
    }
    
    [self setSubviews:self.allDay];
}

- (NSDictionary *)getCurrentMonthDayYear{
    NSCalendar *calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    //NSCalendarUnitWeekOfMonth or NSCalendarUnitWeekOfYear
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth;
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInteger:comps.month] forKey:@"Month"];
    [dict setObject:[NSNumber numberWithInteger:comps.day] forKey:@"Day"];
    [dict setObject:[NSNumber numberWithInteger:comps.year] forKey:@"Year"];
    //NSLog(@"%@-%@-%@", [dict objectForKey:@"year"], [dict objectForKey:@"month"], [dict objectForKey:@"day"]);
    return dict;
}
//一个月有多少天
- (int)getMonthLength:(int)month withYear:(int)year{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    [comps setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:comps];
    NSRange days = [gregorian rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return (int)days.length;
}
//当天是周几
- (int)getWeekdayWithMonth:(int)month withDay:(int)day withYear:(int)year{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    [comps setMonth:month];
    [comps setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:comps];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:date];
    return (int)[weekdayComponents weekday];
}

- (void)clickDay:(DayView *)dayView {
    [self.delegate clickMonthDay:dayView];
}
@end
