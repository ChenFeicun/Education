//
//  BlockView.h
//  Education
//
//  Created by Feicun on 15/4/15.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DayView;
@protocol DayClick <NSObject>

- (void)clickDay:(DayView *)dayView;

@end

@interface DayView : NSView

@property (strong, nonatomic) id<DayClick> delegate;
@property (nonatomic) int state;
@property (nonatomic) int day;
@property (strong, nonatomic) NSString *dayText;
@property (nonatomic) int year;
@property (nonatomic) int month;


- (id)initWithFrame:(NSRect)frameRect andDayText:(NSString *)dayText andMonth:(int)month andYear:(int)year;
- (void)addCircleToCurDate:(int)day;
- (void)showWithLessonType:(NSMutableArray *)lessonTypes;
- (void)showWithType:(NSString *)type;

@end
