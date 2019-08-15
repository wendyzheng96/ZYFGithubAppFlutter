import 'package:flutter/material.dart';

/// 支持顶部和顶部的 TabBar 控件
/// Create by zyf
/// Date: 2019/7/13
class TabBarWidget extends StatefulWidget {
  static const int BOTTOM_TAB = 1;

  static const int TOP_TAB = 2;

  final int type;

  final bool resizeToAvoidBottomPadding;

  final List<Widget> tabItems;

  final List<Widget> tabViews;

  final Color backgroundColor;

  final Color indicatorColor;

  final Widget title;

  final List<Widget> actions;

  final Widget drawer;

  final Widget floatingActionButton;

  final FloatingActionButtonLocation floatingActionButtonLocation;

  final Widget bottomBar;

  final TarWidgetControl tarWidgetControl;

  final ValueChanged<int> onPageChanged;

  TabBarWidget({
    Key key,
    this.type,
    this.tabItems,
    this.tabViews,
    this.backgroundColor,
    this.indicatorColor,
    this.title,
    this.actions,
    this.drawer,
    this.bottomBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomPadding = true,
    this.tarWidgetControl,
    this.onPageChanged
  }): super(key: key);

  @override
  _TabBarState createState() => _TabBarState(type, tabViews, indicatorColor,
      drawer, floatingActionButton, tarWidgetControl, onPageChanged);
}

class _TabBarState extends State<TabBarWidget>
    with SingleTickerProviderStateMixin {
  final int _type;

  final List<Widget> _tabViews;

  final Color _indicatorColor;

  final Widget _drawer;

  final Widget _floatingActionButton;

  final TarWidgetControl _tarWidgetControl;

  final PageController _pageController = PageController();

  final ValueChanged<int> _onPageChanged;

  TabController _tabController;

  _TabBarState(this._type, this._tabViews, this._indicatorColor, this._drawer,
      this._floatingActionButton, this._tarWidgetControl, this._onPageChanged
  ) : super();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabItems.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this._type == TabBarWidget.TOP_TAB) {
      return Scaffold(
        resizeToAvoidBottomPadding: widget.resizeToAvoidBottomPadding,
        floatingActionButton:
            SafeArea(child: _floatingActionButton ?? Container()),
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        persistentFooterButtons:
            _tarWidgetControl == null ? null : _tarWidgetControl.footerButton,
        appBar: AppBar(
          title: widget.title,
          actions: widget.actions,
          bottom: TabBar(
            controller: _tabController,
            tabs: widget.tabItems,
            indicatorColor: _indicatorColor,
            onTap: (index) {
              _onPageChanged?.call(index);
              _pageController.jumpTo(MediaQuery.of(context).size.width * index);
            },
          ),
        ),
        body: PageView(
          controller: _pageController,
          children: _tabViews,
          onPageChanged: (index) {
            _tabController.animateTo(index);
            _onPageChanged?.call(index);
          },
        ),
        bottomNavigationBar: widget.bottomBar,
      );
    }

    ///底部tab bar
    return Scaffold(
      drawer: _drawer,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: widget.title,
      ),
      body: PageView(
        controller: _pageController,
        children: _tabViews,
        onPageChanged: (index) {
          _tabController.animateTo(index);
          _onPageChanged?.call(index);
        },
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).primaryColor,
        child: SafeArea(child: TabBar(
          controller: _tabController,
          tabs: widget.tabItems,
          indicatorColor: _indicatorColor,
          onTap: (index) {
            _onPageChanged?.call(index);
            _pageController.jumpTo(MediaQuery.of(context).size.width * index);
          },
        )),
      ),
    );
  }
}

class TarWidgetControl {
  List<Widget> footerButton = [];
}
