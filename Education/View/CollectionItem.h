//
//  CollectionItem.h
//  Education
//
//  Created by Feicun on 15/4/30.
//  Copyright (c) 2015年 ShuXiaJian.Studio. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//二级传递 传不过去
//@class ItemView;
//
//@protocol ItemClick <NSObject>
//
//- (void)itemClick:(ItemView *)item;
//
//@end
//
//@protocol CollectionItemClick <NSObject>
//
//- (void)collectionItemClick:(ItemView *)item;
//
//@end

@interface ItemView : NSBox

#warning 应该有个 (老师/学生)类属性 保存信息
//- (void)setImage:(NSImage *)image andText:(NSString *)text andType:(NSString *)type;
- (void)setRepresentedObject:(id)representedObject;

@end

@interface CollectionItem : NSCollectionViewItem

//@property (strong, nonatomic) id<CollectionItemClick> delegate;

@end



