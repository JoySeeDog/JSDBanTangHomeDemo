//
//  JQScrollViewController.m
//  JQScrollViewDemo
//
//  Created by jianquan on 2016/11/8.
//  Copyright © 2016年 JoySeeDog. All rights reserved.
//

#import "JQTableViewController.h"
#import "UIView+Extension.h"
#import "JQHeaderView.h"
#import "JQSectionPageView.h"
#import "SDCycleScrollView.h"
#import "MJRefresh.h"
#import "JQRefreshHeaader.h"
#import "JQBTHomeTableViewCell.h"
#import "JQBTHomeRecomandModel.h"


#define SCREEN_HEIGHT                      [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH                       [UIScreen mainScreen].bounds.size.width
#define SCALE_6                                                   (SCREEN_WIDTH / 375)
#define NAVBAR_CHANGE_POINT 50

@interface JQTableViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JQSectionPageView *jqSectionPageView;
@property (nonatomic, strong) JQHeaderView *jqHeaderView;
@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) JQRefreshHeaader *jqRefreshHeader;


@property (nonatomic, strong) NSMutableArray *modelArray;




@end

@implementation JQTableViewController

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
    
    [self loadData];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.modelArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JQBTHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JQBTHomeTableViewCell class])];
    
    cell.homeRecomandModel = [self.modelArray objectAtIndex:indexPath.row];
    return cell;
}



#pragma observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    CGFloat tableViewoffsetY = self.tableView.contentOffset.y;
    
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
        
    }else if (tableViewoffsetY > 136){
        self.jqSectionPageView.frame = CGRectMake(0, 64, SCREEN_WIDTH, 60);
        self.cycleScrollView.frame = CGRectMake(0, -136, SCREEN_WIDTH, 200);
    }
}

- (void)loadData {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        NSArray * dataArray = [[dic objectForKey:@"data"] objectForKey:@"topic"];
        
        
        [self.modelArray removeAllObjects];
        for (unsigned long i = 0; i<[dataArray count]; i++) {
            JQBTHomeRecomandModel *model = [[JQBTHomeRecomandModel alloc] init];
            NSString *string = [NSString stringWithFormat:@"recomand_%02ld%@",i+1,@".jpg"];
            UIImage *image  = [UIImage imageNamed:string];

            model.placeholderImage = image;
            
            NSDictionary *itemDic = dataArray[i];
            model.picUrl = [itemDic objectForKey:@"pic"];
            model.title = [itemDic objectForKey:@"title"];
            model.views = [itemDic objectForKey:@"views"];
            model.likes = [itemDic objectForKey:@"likes"];
            
            NSDictionary *userDic = [itemDic objectForKey:@"user"];
            model.author = [userDic objectForKey:@"nickname"];
            
            [self.modelArray addObject:model];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
        
        
        NSLog(@"dataArray is%ld",[dataArray count]);
        
    });
}


#pragma -mark lazy load

- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}

- (SDCycleScrollView *)cycleScrollView {
    if (!_cycleScrollView) {
        
        NSMutableArray *imageMutableArray = [NSMutableArray array];
        for (int i = 1; i<9; i++) {
            NSString *imageName = [NSString stringWithFormat:@"cycle_%02d.jpg",i];
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
        _jqRefreshHeader.tableView = self.tableView;
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
        [_tableView registerClass:[JQBTHomeTableViewCell class] forCellReuseIdentifier:NSStringFromClass([JQBTHomeTableViewCell class])];
        
        
        UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 260)];
        tableHeaderView.backgroundColor = [UIColor whiteColor];
        
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(200, 0, 0, 0);
        _tableView.tableHeaderView = tableHeaderView;
        
        //添加监听者
       [_tableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
        
    }
    return _tableView;
}


@end
