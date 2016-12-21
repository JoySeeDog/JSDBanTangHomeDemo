> 很久以前，一个学弟的曾问过我如何实现半糖iOS版本首页效果，我当时一看觉得这个效果挺酷炫，然后去github上搜了一下，很多自称是仿半糖首页的，我下载之后发现其实很多代码都没有实现主要的代码。有些代码也做了一些简单的尝试，但是最后都放弃了，所以说这个效果还是没有很好的实现。我于是打算研究一下这个有趣的效果，经过工作之余一段时间的研究。有时候路上也会想一想，做了很多的尝试，一点一点的把遇到的问题解决了。于是写下这篇文章，把自己的一些尝试和想法与大家分享。

有的开发者可能会觉得这么简单的东西别拿来忽悠我，可以自己亲自尝试去做一个，并没有想象的那么简单。

# 实现上滑的的效果
这一步是首页效果的基础，实现这一步后，才有继续其它步的必要，这里面难度不是很大，关键是要想到一个好方法不容易。下面就具体讲讲是如何实现的。

有一点可以确定的是，使用的肯定是KVO的做法。通过监听`contentOffset`的变化来进行相应的处理。但是具体怎么做，怎么来划分层次，真的是一个让人脑壳痛的问题。

怎么下手呢，开始真的毫无思绪，然后想到了一个利器，Reveal。不管别的，先用Reveal看看图层结构再说。关于Reveal的使用，在我的另外一篇文章里面有。[使用Reveal查看任意iOS App的图层结构](http://blog.csdn.net/zhouzhoujianquan/article/details/52964559)。通过图层查看后，下面是一个ScrollView，上面是几个TableView。于是这个立刻把我带入了坑，很多网上的Demo都是这样尝试，把TableView放到ScrollView上面，然后对它们的`contentOffset`都添加监听。通过判断偏移量来禁用TableView或是Scrollew的手势。经过无数次的尝试最后还是放弃了，手势冲突这个问题不可能这样很好的解决。

然后我搜了资料，有人说可以使用`contentInset`这个属性，这是用来设定`ScrollView`及其子类的内容显示区域，通过改变这个属性的值，达到类似的滑动的效果。也就是在KVO的实现方法里面不断的改变`contentInset`的值，然后模拟上推的效果。没有试过这个属性的可以尝试一下。我使用之后，出现的问题就是卡顿，特别卡，而且很难控制值，这就造成了完全没有流畅性可言。间接说明了使用这个根本没法达到这个效果。

然后我实在是想不到什么好办法，打算用`UISwipGesturer`,不过想想这就算了吧。太愚蠢了，而且也会很麻烦。像我这样懒的，总想少写几行代码。怎么办呢，再想想。有一天在地铁上拿出半糖的APP来研究，突然灵光一闪，想到了。因为既然这么流畅，那一定是使用了原生的`UITableView`,然后再使用`scrollIndicatorInsets`这个属性就可以伪装出`tableView`是从下面开始的效果,然后我的`tableView`从坐标(0,0)的位置开始。上面添加一个空白的View把内容往下面撑即可实现类似的效果。如图(为了便于看清楚布局，我给每个视图留了一个边距)

![这里写图片描述](http://img.blog.csdn.net/20161220224723354?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvemhvdXpob3VqaWFucXVhbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)


能想到这一步其实完成了很大的工作了。接下来就是给上面的搜索框和轮播页面添加坐标变化的事件了。

# 头部三个View的坐标改变

给TableView添加监听，然后在如下方法里面根据`contentOffset`的值改变轮播和分类选择控价的坐标。

```Objective-C

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    UITableView *tableView = (UITableView *)object;
        
    if (![keyPath isEqualToString:@"contentOffset"]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    CGFloat tableViewoffsetY = tableView.contentOffset.y;
    self.lastTableViewOffsetY = tableViewoffsetY;
    
    if ( tableViewoffsetY>=0 && tableViewoffsetY<=136) {
        self.segmentScrollView.frame = CGRectMake(0, 200-tableViewoffsetY, SCREEN_WIDTH, 40);
        self.cycleScrollView.frame = CGRectMake(0, 0-tableViewoffsetY, SCREEN_WIDTH, 200); 
    }else if( tableViewoffsetY < 0){
        self.segmentScrollView.frame = CGRectMake(0, 200, SCREEN_WIDTH, 40);
        self.cycleScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
        
    }else if (tableViewoffsetY > 136){
        self.segmentScrollView.frame = CGRectMake(0, 64, SCREEN_WIDTH, 40);
        self.cycleScrollView.frame = CGRectMake(0, -136, SCREEN_WIDTH, 200);
    }
}

```

我们需要添加一个坐标的限制，因为偏移量有时候会无限大或者是无限小。而我们的轮播和分类选择器的区间是固定不变的。所以需要找对坐标进行限制，一旦偏移量超过了这个坐标就不进行改变，而是保持固定的值不变。

为了模块的划分清晰一些，我把上面的搜素框单独的划分到了`JQHeaderView`里面。所以需要把外面的`tableView`传到里面去。然后在里面同样进行了监听然后事件处理。

```Object-C
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if (![keyPath isEqualToString:@"contentOffset"]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    UITableView *tableView = (UITableView *)object;
    CGFloat tableViewoffsetY = tableView.contentOffset.y;
    
    UIColor * color = [UIColor whiteColor];
    CGFloat alpha = MIN(1, tableViewoffsetY/136);
    
    self.backgroundColor = [color colorWithAlphaComponent:alpha];
    
    if (tableViewoffsetY < 125){
        
        [UIView animateWithDuration:0.25 animations:^{
            self.searchButton.hidden = NO;
            [self.emailButton setBackgroundImage:[UIImage imageNamed:@"home_email_black"] forState:UIControlStateNormal];
            self.searchBar.frame = CGRectMake(-(self.width-60), 30, self.width-80, 30);
            self.emailButton.alpha = 1-alpha;
            self.searchButton.alpha = 1-alpha;
            
            
        }];
    } else if (tableViewoffsetY >= 125){
        
        [UIView animateWithDuration:0.25 animations:^{
            self.searchBar.frame = CGRectMake(20, 30, self.width-80, 30);
            self.searchButton.hidden = YES;
            self.emailButton.alpha = 1;
            [self.emailButton setBackgroundImage:[UIImage imageNamed:@"home_email_red"] forState:UIControlStateNormal];
        }];
    }
    
}
```
做完以上工作后，我们应该可以看到的是这样的效果。

[![Screenshot](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome01.gif)](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome01.gif)
--------

# 添加下拉刷新的文字效果

下拉刷新我单独分离出来了`JQRefreshHeaader`文件。实现的原理一样是用了KVO。使用偏移量进行相应的图片替换，在某个偏移量开始出现图片，在另一个偏移量结束。这中间每两个像素的偏移量替换为一张图片， 然后隐藏其它所有的图片，就显示当前的图片，当偏移量的绝对值大于某个值时，显示所有的图片，小于某个值时隐藏所有的图片。当然这里面还值得推敲，感觉可以简化一些步骤， 

```Objective-C

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    
    if (![keyPath isEqualToString:@"contentOffset"]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    UITableView *tableView = (UITableView *)object;
    CGFloat tableViewoffsetY = tableView.contentOffset.y;
    
    if ( tableViewoffsetY <= 0  &&tableViewoffsetY > -35) {
        
        [self hideAllImageView];
        
    }else if(tableViewoffsetY < -35){
       
        if (tableViewoffsetY < -59) {

            [self showAllImageView];
        }else {
            CGFloat offset = fabs(tableViewoffsetY)-35;
            NSInteger imageCount = offset/2.0;//两个偏移量切换一张图片
            [self hideImageViewExcept:imageCount];
        }
      
    }else if (tableViewoffsetY <136){
        
    }
    
}

```
把这里面使用的图片是我自己用PS做的，所以看起来很丑，实现后的效果如下

[![Screenshot](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome02.gif)](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome02.gif)


# 添加分类滑动

首先是单纯的实现左右滑动的效果，这里我使用了简单的ScrollView来实现这个效果。上面的分类选择是一个ScrollView，下面的也是ScrlloView，在切换时候修改对应的偏移量即可。当然实现方式很多，网上也有很多的框架，不过该项目的分类选择控件需要实现上下滑动，所以我还是自己实现了。实现原理很简单

首先是点击上面的分类控件实现下面ScrollView的滑动。我们只需要在改变改变分类控件偏移量的同时改变下面内容ScrollView的偏移量

```Objective

 [UIView animateWithDuration:0.3 animations:^{
        if (index == 0) {
            self.currentSelectedItemImageView.frame = CGRectMake(PADDING, self.segmentScrollView.frame.size.height - 2,currentButton.frame.size.width, 2);
            
        }else{
            
            UIButton *preButton = self.titleButtons[index - 1];
            
            float offsetX = CGRectGetMinX(preButton.frame)-PADDING*2;
            
            [self.segmentScrollView scrollRectToVisible:CGRectMake(offsetX, 0, self.segmentScrollView.frame.size.width, self.segmentScrollView.frame.size.height) animated:YES];
            
            self.currentSelectedItemImageView.frame = CGRectMake(CGRectGetMinX(currentButton.frame), self.segmentScrollView.frame.size.height-2, currentButton.frame.size.width, 2);
        }
        self.bottomScrollView.contentOffset = CGPointMake(SCREEN_WIDTH *index, 0);
        
    }];

```

然后们在滑动下面的ScrollView的时候滑动在代理方法里面分类选择控件也跟着进行滑动即可。

```Objective-C
    [UIView animateWithDuration:0.3 animations:^{
        if (index == 0) {
            self.currentSelectedItemImageView.frame = CGRectMake(PADDING, self.segmentScrollView.frame.size.height - 2,currentButton.frame.size.width, 2);
            
        }else{
            
            
            UIButton *preButton = self.titleButtons[index - 1];
            
            float offsetX = CGRectGetMinX(preButton.frame)-PADDING*2;
            
            [self.segmentScrollView scrollRectToVisible:CGRectMake(offsetX, 0, self.segmentScrollView.frame.size.width, self.segmentScrollView.frame.size.height) animated:YES];
            
            self.currentSelectedItemImageView.frame = CGRectMake(CGRectGetMinX(currentButton.frame), self.segmentScrollView.frame.size.height-2, currentButton.frame.size.width, 2);
        }
        
    }];


```

这样简单实现的滑动控件肯定有很多值得优化的地方，最简单优化就是把下面的`UIScrollView`换成`UICollectionView`，这样就可以复用Cell从而优化内存。

实现后的基本效果如下

[![Screenshot](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome03.gif)](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome03.gif)





# 为分类滑动添加上下滑动的交互
到这一步感觉这也是一件非常费脑子的事情，每一个分类都要能滑动上面的分类控件和推荐控件，而且在滑动到任意位置之后，切换分类后还需要能够继续滑动视图。

首先我们来解决第一个问题，如何让所有的分类都可以有类似的效果呢。其实很简单，弄一个数组，把所有的控制器里面的TableView放到里面去，然后给所有的TableView的contentOffset都添加KVO就好了。当然基本思路就是这样，具体实践的时候可能会遇到很多的问题，读者可以自行尝试研究。当然我们的下拉刷新控件也需要添加到每一个tableView上面

```Objective-C

for (int i = 0; i<CATEGORY.count; i++) {
            
            JSDTableViewController *jsdTableViewController = [[JSDTableViewController alloc] init];
            jsdTableViewController.view.frame = CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            
            jsdTableViewController.view.backgroundColor = colors[i];
            [self.bottomScrollView addSubview:jsdTableViewController.view];
            
            [self.controlleres addObject:jsdTableViewController];
            [self.tableViews addObject:jsdTableViewController.tableView];
            
            //下拉刷新动画
           JQRefreshHeaader *jqRefreshHeader  = [[JQRefreshHeaader alloc] initWithFrame:CGRectMake(0, 212, SCREEN_WIDTH, 30)];
            jqRefreshHeader.backgroundColor = [UIColor whiteColor];
            jqRefreshHeader.tableView = jsdTableViewController.tableView;
            [jsdTableViewController.tableView.tableHeaderView addSubview:jqRefreshHeader];
            
            
            NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
            [jsdTableViewController.tableView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
            
        }

```

这样的话，我在切换之后其它的控制器也可以实现上滑的效果。不过如果我滑了一部分没有到最上面或是最下面的话，就会出现错乱的情况。要保持各个控制器能够连续滑动。我们可以记录下上一次的偏移量，然后在切换的时候对其它的tableView也设置同样的偏移量，这样就可以保证都保持统一的偏移量，当然我做了类似半糖的判断，就是当偏移量大于最大值当时候设置为最大值，小于最小值的时候设置为0.

```Objective-C

self.currentTableView  = self.tableViews[index];
    for (UITableView *tableView in self.tableViews) {
        
        if ( self.lastTableViewOffsetY>=0 &&  self.lastTableViewOffsetY<=136) {
            tableView.contentOffset = CGPointMake(0,  self.lastTableViewOffsetY);
            
        }else if(  self.lastTableViewOffsetY < 0){
            tableView.contentOffset = CGPointMake(0, 0);
            
        }else if ( self.lastTableViewOffsetY > 136){
            tableView.contentOffset = CGPointMake(0, 136);
        }
        
    }
 

```
最后实现的效果如下所示，感觉还可以吧。

[![Screenshot](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome04.gif)](https://github.com/JoySeeDog/JSDBanTangHomeDemo/blob/master/gif/bantanghome04.gif)

# 最后

里面的点击事件我都没有添加，这些都很简单。。不想浪费时间在这上面。

工程里面的`Resource`目录下是我抓包到的一些数据，为了防止半糖修改权限下载不到图片，我把需要的图片都提前下载一份，一旦下载失败就使用本地图片，还有一些自己的图片。为了方便大家学习使用，我没有把图片文件放入`Assets.xcassets`目录下，因为放入这里，对于需要图片学习复用的时候需要一张图片一只图片拷贝出来，费时间费力气。里面关于半糖的数据仅用于交流和学习，若用于商业用途，后果自负。

欢迎提issue,博客地址[ 半糖iOS版首页实现与基本原理揭秘](http://blog.csdn.net/zhouzhoujianquan/article/details/53769501)或者直接邮件联系我如果觉得满意，请给个Satr。

