//
//  FuncBlockView.h
//  Education
//
//  Created by Feicun on 15/4/21.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FuncBlockView;

@protocol BlockClick <NSObject>

- (void)clickBlock:(FuncBlockView *)blockView;

@end

@interface FuncBlockView : NSView

@property (strong, nonatomic) id<BlockClick> delegate;
@property (nonatomic) NSString *type;//听说读写
@property (nonatomic) int time;//几点
@property (nonatomic) BOOL isSelected;//是否被选择
@property (nonatomic) BOOL isEditable;//是否可以被编辑

//@property (nonatomic) BOOL isClick;//是否被点击(只有在第一次被选中的情况下才算被点击)
//@property (nonatomic) NSPoint curPoint;//当前鼠标所在坐标

- (id)initWithFrame:(NSRect)frameRect withType:(NSString *)type andEditable:(BOOL)isEditable;
- (void)didSelected:(BOOL)selected;//改变Block的状态
//- (void)setEditable:(BOOL)editable;//设置是否可编辑
@end
