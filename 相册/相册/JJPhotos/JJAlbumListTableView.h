//
//  JJAlbumListTableView.h
//  相册
//
//  Created by 16 on 2018/7/17.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJAblumInfo.h"


@protocol JJAlbumListTableViewDelegate <NSObject>
///点击了某一行cell
- (void)JJAlbumListTableViewDidSelectAlbum:(JJAblumInfo *)album;
@end
@interface JJAlbumListTableView : UITableView

///代理
@property (nonatomic , weak) id<JJAlbumListTableViewDelegate>jj_delegate;
///设置数据源
- (void)setUpItems:(NSArray <JJAblumInfo*>*)items;
@end
