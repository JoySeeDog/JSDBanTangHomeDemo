//
//  JQBTHomeRecomandModel.h
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/11/23.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JSDTHomeRecomandModel : NSObject
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, copy) NSString *picUrl;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *views;
@property (nonatomic, copy) NSString *likes;
@end
