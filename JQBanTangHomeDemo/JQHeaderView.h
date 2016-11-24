//
//  JQHeaderView.h
//  JQScrollViewDemo
//
//  Created by jianquan on 2016/11/10.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AnimalName){
    Dog,
    Cow,
    Hen,
    Cat,
    Pig
};

@interface JQHeaderView : UIView
@property (nonatomic, weak) UITableView *tableView;


@end
