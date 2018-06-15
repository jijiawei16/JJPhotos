//
//  JJAblumInfo.m
//  封装一些小控件
//
//  Created by 16 on 2018/4/9.
//  Copyright © 2018年 冀佳伟. All rights reserved.
//

#import "JJAblumInfo.h"

@implementation JJAblumInfo

+ (instancetype)infoFromResult:(PHFetchResult *)result collection:(PHAssetCollection *)collection {
    
    // 将相册中的信息保存在模型中
    JJAblumInfo * ablumInfo = [[JJAblumInfo alloc]init];
    ablumInfo.ablumName = collection.localizedTitle;
    ablumInfo.count = result.count;
    ablumInfo.coverAsset = result[0];
    ablumInfo.assetCollection = collection;
    return ablumInfo;
}

@end
