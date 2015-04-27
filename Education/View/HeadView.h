//
//  HeadView.h
//  Education
//
//  Created by Feicun on 15/4/20.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ToadyClick <NSObject>

- (void)clickToday;
- (void)clickPrevious;
- (void)clickNext;

@end

@interface HeadView : NSView

@property (strong, nonatomic) NSString *dateText;
@property (strong, nonatomic) id<ToadyClick> delegate;

@end
