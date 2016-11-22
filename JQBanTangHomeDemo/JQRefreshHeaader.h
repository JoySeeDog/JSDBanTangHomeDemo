//
//  JQRefreshHeaader.h
//  JQBanTangHomeDemo
//
//  Created by jianquan on 2016/11/21.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const JQTableKeyPathContenOffSet;

@interface JQRefreshHeaader:UIView
@property (nonatomic, assign) CGFloat table_offsety;
@property (nonatomic, weak) UITableView *tableView;

@end
