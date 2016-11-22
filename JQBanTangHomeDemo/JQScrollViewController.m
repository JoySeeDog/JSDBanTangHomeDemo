//
//  JQScrollViewController.m
//  JQScrollViewDemo
//
//  Created by jianquan on 2016/11/8.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JQScrollViewController.h"
#import "UIView+Extension.h"
#import "JQHeaderView.h"
#import "JQSectionPageView.h"
#import "SDCycleScrollView.h"
#import "MJRefresh.h"
#import "JQRefreshHeaader.h"


#define SCREEN_HEIGHT                      [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH                       [UIScreen mainScreen].bounds.size.width
#define SCALE_6                                                   (SCREEN_WIDTH / 375)
#define NAVBAR_CHANGE_POINT 50

@interface JQScrollViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JQSectionPageView *jqSectionPageView;
@property (nonatomic, strong) JQHeaderView *jqHeaderView;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) JQRefreshHeaader *jqRefreshHeader;




@end

@implementation JQScrollViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        [self.view addSubview:self.tableView];
        [self.view addSubview:self.jqSectionPageView];
        [self.view addSubview:self.cycleScrollView];
        [self.view addSubview:self.jqHeaderView];
        [self.tableView.tableHeaderView addSubview:self.jqRefreshHeader];
        

        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    cell.textLabel.text = @"测试数据";
    cell.imageView.image = [UIImage imageNamed:@"favor"];
    return cell;
}



#pragma observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    CGRect rect = self.tableView.frame;
    CGFloat tableViewoffsetY = self.tableView.contentOffset.y;
    
    NSLog(@"tableView offset is %lf",tableViewoffsetY);
    NSLog(@"self.segmentView.y %lf",self.jqSectionPageView.y);
    if ( tableViewoffsetY>=0 && tableViewoffsetY<=136) {
        self.jqSectionPageView.frame = CGRectMake(0, 200-tableViewoffsetY, SCREEN_WIDTH, 60);
        self.cycleScrollView.frame = CGRectMake(0, 0-tableViewoffsetY, SCREEN_WIDTH, 200);
        
        UIColor * color = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1];
        
        if (tableViewoffsetY > NAVBAR_CHANGE_POINT) {
            CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - tableViewoffsetY) / 64));
            self.jqHeaderView.backgroundColor = [color colorWithAlphaComponent:alpha];
        } else {
            self.jqHeaderView.backgroundColor = [color colorWithAlphaComponent:0];
            
        }
        
    }else if( tableViewoffsetY < 0){
        self.jqSectionPageView.frame = CGRectMake(0, 200, SCREEN_WIDTH, 60);
        self.cycleScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
        
    
        // self.tableView.contentInset = UIEdgeInsetsMake(200, 0, 0, 0);
    }else if (tableViewoffsetY > 136){
        self.jqSectionPageView.frame = CGRectMake(0, 64, SCREEN_WIDTH, 60);
        self.cycleScrollView.frame = CGRectMake(0, -136, SCREEN_WIDTH, 200);
    }
}


#pragma -mark lazy load

- (SDCycleScrollView *)cycleScrollView {
    if (!_cycleScrollView) {
        
        NSMutableArray *imageMutableArray = [NSMutableArray array];
        for (int i = 1; i<9; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cycle_%02d.jpg",i];
            NSLog(@"------%@",imageName);
            [imageMutableArray addObject:imageName];
        }
        
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200) imageNamesGroup:imageMutableArray];
        
    
    }
    return _cycleScrollView;
}

- (JQHeaderView *)jqHeaderView {
    if (!_jqHeaderView) {
        _jqHeaderView = [[JQHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
        _jqHeaderView.backgroundColor = [UIColor clearColor];
    }
    return _jqHeaderView;
}


- (JQSectionPageView *)jqSectionPageView {
    if (!_jqSectionPageView) {
        _jqSectionPageView = [[JQSectionPageView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_WIDTH, 60)];
        _jqSectionPageView.backgroundColor = [UIColor greenColor];
    }
    return _jqSectionPageView;
}


- (JQRefreshHeaader *)jqRefreshHeader {
    if (!_jqRefreshHeader) {
        _jqRefreshHeader  = [[JQRefreshHeaader alloc] initWithFrame:CGRectMake(0, 230, SCREEN_WIDTH, 30)];
        _jqRefreshHeader.backgroundColor = [UIColor whiteColor];
        _jqRefreshHeader.tableView = self.tableView;
    }
    return _jqRefreshHeader;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView  = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        
        
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 260)];
        tableHeaderView.backgroundColor = [UIColor whiteColor];
        
       
        
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(200, 0, 0, 0);
        _tableView.tableHeaderView = tableHeaderView;
        
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            //Call this Block When enter the refresh status automatically
        }];
        
//        _tableView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
//            //Call this Block When enter the refresh status automatically
//        }];
   
        //添加监听者
       [_tableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
        
    }
    return _tableView;
}


@end
