import 'package:flutter/material.dart';
import 'package:github_app_flutter/common/style/style.dart';

/// 下拉刷新，上拉加载更多数据
/// Create by zyf
/// Date: 2019/7/17
class DynamicListView extends StatefulWidget {
  final Function itemBuilder;

  final Function dataRequester;

  final Function initRequester;

  final bool isLoadComplete;

  final Color dividerColor;

  final GlobalKey<RefreshIndicatorState> refreshKey;

  final bool needHeader;

  DynamicListView.build(
      {Key key,
      @required this.itemBuilder,
      @required this.dataRequester,
      @required this.initRequester,
      this.isLoadComplete = false,
      this.dividerColor,
      this.refreshKey,
      this.needHeader = false})
      : assert(itemBuilder != null),
        assert(dataRequester != null),
        assert(initRequester != null),
        super(key: key);

  @override
  State createState() => DynamicListViewState(refreshKey, needHeader);
}

class DynamicListViewState extends State<DynamicListView> {

  final bool needHeader;

  GlobalKey<RefreshIndicatorState> refreshKey;

  bool isPerformingRequest = false;

  ScrollController _controller = ScrollController();

  List _dataList = List();

  DynamicListViewState(this.refreshKey, this.needHeader);

  @override
  void initState() {
    super.initState();
    if(refreshKey == null) {
      refreshKey = GlobalKey<RefreshIndicatorState>();
    }
    showRefreshLoading();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  showRefreshLoading() {
    Future.delayed(const Duration(seconds: 0), () {
      refreshKey.currentState.show().then((e) {});
      return true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color loadingColor = Theme.of(context).primaryColor;
    return RefreshIndicator(
      key: refreshKey,
      color: loadingColor,
      onRefresh: this._onRefresh,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(
          height: 1.0,
          color: widget.dividerColor ?? Colors.transparent,
        ),
        itemCount: _getListCount(),
        itemBuilder: (context, index) {
          return _getItem(index, loadingColor);
        },
        controller: _controller,
      ),
    );
  }

  ///根据配置状态返回实际列表数量
  ///实际上这里可以根据你的需要做更多的处理
  ///比如多个头部，是否需要空页面，是否需要显示加载更多。
  _getListCount() {
    ///是否需要头部
    if (needHeader) {
      ///如果需要头部，用Item 0 的 Widget 作为ListView的头部
      ///列表数量大于0时，因为头部和底部加载更多选项，需要对列表数据总数+2
      return (_dataList.length > 0)
          ? _dataList.length + 2
          : _dataList.length + 1;
    } else {
      ///如果不需要头部，在没有数据时，固定返回数量1用于空页面呈现
      ///如果有数据,因为需要加载更多选项，需要对列表数据总数+1
      return _dataList.length + 1;
    }
  }

  ///根据配置状态返回实际列表渲染Item
  _getItem(int index, Color loadingColor) {
    if (!needHeader && index == _dataList.length && _dataList.length != 0) {
      ///如果不需要头部，并且数据不为0，当index等于数据长度时，渲染加载更多Item（因为index是从0开始）
      return opacityLoadingProgress(isPerformingRequest, loadingColor);
    } else if (needHeader &&
        index == _getListCount() - 1 &&
        _dataList.length != 0) {
      ///如果需要头部，并且数据不为0，当index等于实际渲染长度 - 1时，渲染加载更多Item（因为index是从0开始）
      return opacityLoadingProgress(isPerformingRequest, loadingColor);
    } else if (!needHeader && _dataList.length == 0) {
      ///如果不需要头部，并且数据为0，渲染空页面
      return _getEmpty();
    } else {
      ///回调外部正常渲染Item，如果这里有需要，可以直接返回相对位置的index
      return widget.itemBuilder(_dataList, context, index);
    }
  }

  Widget _getEmpty() => Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text('暂无数据'),
        ),
      );

  /// 刷新 数据初始化
  Future<Null> _onRefresh() async {
    List initDataList = await widget.initRequester();
    this.setState(() => this._dataList = initDataList);
    return;
  }

  /// 加载更多数据
  _loadMore() async {
    if (!widget.isLoadComplete) {
      this.setState(() => isPerformingRequest = true);
      List newDataList = await widget.dataRequester();
      if (newDataList != null) {
        if (newDataList.length == 0) {
          double edge = 50.0;
          double offsetFromBottom = _controller.position.maxScrollExtent -
              _controller.position.pixels;
          if (offsetFromBottom < edge) {
            _controller.animateTo(
              _controller.offset - (edge - offsetFromBottom),
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        } else {
          _dataList.addAll(newDataList);
        }
      }
      this.setState(() => isPerformingRequest = false);
    }
  }

  Widget loadingProgress(loadingColor) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
      ),
    );
  }

  Widget opacityLoadingProgress(isPerformingRequest, loadingColor) {
    if (widget.isLoadComplete) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),
        child: Text(
          '——我是有底线的——',
          style: ZStyles.smallTextSecondary,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        ),
      ),
    );
  }
}
