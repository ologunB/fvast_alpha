import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';

class DrawerScaffold extends StatefulWidget {
  final MenuView menuView;
  final Screen contentView;
  final AppBarProps appBar;
  final bool showAppBar;
  final DrawerScaffoldController controller;
  final double percentage;
  final double cornerRadius;

  final List<BoxShadow> contentShadow;

  DrawerScaffold({
    this.appBar,
    this.contentShadow = const [
      BoxShadow(
        color: const Color(0x44000000),
        offset: const Offset(0.0, 5.0),
        blurRadius: 20.0,
        spreadRadius: 10.0,
      ),
    ],
    this.menuView,
    this.cornerRadius = 10.0,
    this.contentView,
    this.percentage = 0.8,
    this.showAppBar = true,
    this.controller,
  });

  @override
  _DrawerScaffoldState createState() => new _DrawerScaffoldState();
}

class _DrawerScaffoldState extends State<DrawerScaffold>
    with TickerProviderStateMixin {
  MenuController menuController;
  Curve scaleDownCurve = new Interval(0.0, 0.3, curve: Curves.easeOut);
  Curve scaleUpCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideOutCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);
  Curve slideInCurve = new Interval(0.0, 1.0, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    menuController = new MenuController(
      vsync: this,
    )..addListener(() => setState(() {}));

    updateDrawerState();
  }

  @override
  void dispose() {
    menuController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateDrawerState();
  }

  void updateDrawerState() {
    if (widget.controller != null) {
      if (widget.controller.open)
        menuController.open();
      else
        menuController.close();
      widget.controller.menuController = menuController;
    }
  }

  Widget createAppBar() {
    if (!widget.showAppBar) return null;
    if (widget.appBar == null)
      return AppBar(
        backgroundColor: widget.contentView.appBarColor == null
            ? Colors.transparent
            : widget.contentView.appBarColor,
        elevation: 0.0,
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () {
              menuController.toggle();
            }),
        title: new Text(
          widget.contentView.title,
        ),
      );
    else
      return new AppBar(
          backgroundColor: widget.appBar.backgroundColor,
          leading: new IconButton(
              icon: widget.appBar.leadingIcon,
              onPressed: () {
                menuController.toggle();
              }),
          title: widget.appBar.title,
          automaticallyImplyLeading: widget.appBar.automaticallyImplyLeading,
          actions: widget.appBar.actions,
          flexibleSpace: widget.appBar.flexibleSpace,
          bottom: widget.appBar.bottom,
          elevation: widget.appBar.elevation,
          brightness: widget.appBar.brightness,
          iconTheme: widget.appBar.iconTheme,
          textTheme: widget.appBar.textTheme,
          primary: widget.appBar.primary,
          centerTitle: widget.appBar.centerTitle,
          titleSpacing: widget.appBar.titleSpacing,
          toolbarOpacity: widget.appBar.toolbarOpacity,
          bottomOpacity: widget.appBar.bottomOpacity);
  }

  double startDx = 0.0;
  double percentage = 0.0;
  bool isOpening = false;

  Widget body;

  String selectedItemId;

  createContentDisplay() {
    if (selectedItemId != widget.menuView.selectedItemId || body == null)
      body = widget.contentView.contentBuilder(context);
    selectedItemId = widget.menuView.selectedItemId;

    double maxSlideAmount = widget.menuView.maxSlideAmount;
    Widget content = Center(
      child: Container(
        child: GestureDetector(
          child: AbsorbPointer(
            absorbing: menuController.isOpen() && widget.showAppBar,
            child: new Scaffold(
              backgroundColor: Colors.transparent,
              // appBar: createAppBar(),
              body: body,
            ),
          ),
          onTap: () {
            if (menuController.isOpen()) menuController.close();
          },
          onHorizontalDragStart: (details) {
            isOpening = !menuController.isOpen();
            if (menuController.isOpen() &&
                details.globalPosition.dx < maxSlideAmount + 60) {
              startDx = details.globalPosition.dx;
            } else if (details.globalPosition.dx < 60)
              startDx = details.globalPosition.dx;
            else {
              startDx = -1;
            }
          },
          onHorizontalDragUpdate: (details) {
            if (startDx == -1) return;
            double dx = (details.globalPosition.dx - startDx);
            if (isOpening && dx > 0 && dx <= maxSlideAmount) {
              percentage = Utils.fixed(dx / maxSlideAmount, 3);

              menuController._animationController
                  .animateTo(percentage, duration: Duration(microseconds: 0));
              menuController._animationController
                  .notifyStatusListeners(AnimationStatus.forward);
            } else if (!isOpening && dx <= 0 && dx >= -maxSlideAmount) {
              percentage = Utils.fixed(1.0 + dx / maxSlideAmount, 3);

              menuController._animationController
                  .animateTo(percentage, duration: Duration(microseconds: 0));
              menuController._animationController
                  .notifyStatusListeners(AnimationStatus.reverse);
            }
          },
          onHorizontalDragEnd: (details) {
            if (startDx == -1) return;
            if (percentage < 0.5) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
        ),
      ),
    );

    bool isIOS = Platform.isIOS;

    return zoomAndSlideContent(new Container(
        decoration: new BoxDecoration(
          image: widget.contentView.background,
          color: widget.contentView.color,
        ),
        child: isIOS
            ? content
            : WillPopScope(
                child: content,
                onWillPop: () {
                  return new Future(() {
                    if (menuController.isOpen()) {
                      menuController.close();
                      return false;
                    }
                    return true;
                  });
                })));
  }

  zoomAndSlideContent(Widget content) {
    double maxSlideAmount = widget.menuView.maxSlideAmount;

    var slidePercent, scalePercent;
    switch (menuController.state) {
      case MenuState.closed:
        slidePercent = 0.0;
        scalePercent = 0.0;
        break;
      case MenuState.open:
        slidePercent = 1.0;
        scalePercent = 1.0;
        break;
      case MenuState.opening:
        slidePercent = slideOutCurve.transform(menuController.percentOpen);
        scalePercent = scaleDownCurve.transform(menuController.percentOpen);
        break;
      case MenuState.closing:
        slidePercent = slideInCurve.transform(menuController.percentOpen);
        scalePercent = scaleUpCurve.transform(menuController.percentOpen);
        break;
    }

    final slideAmount = maxSlideAmount * slidePercent;
    final contentScale = 1.0 - ((1.0 - widget.percentage) * scalePercent);
    final cornerRadius = widget.cornerRadius * menuController.percentOpen;

    return new Transform(
      transform: new Matrix4.translationValues(slideAmount, 0.0, 0.0)
        ..scale(contentScale, contentScale),
      alignment: Alignment.centerLeft,
      child: new Container(
        decoration: new BoxDecoration(
          boxShadow: widget.contentShadow,
        ),
        child: new ClipRRect(
            borderRadius: new BorderRadius.circular(cornerRadius),
            child: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [widget.menuView, createContentDisplay()],
    );
  }
}

class DrawerScaffoldMenuController extends StatefulWidget {
  final DrawerScaffoldBuilder builder;

  DrawerScaffoldMenuController({
    this.builder,
  });

  @override
  DrawerScaffoldMenuControllerState createState() {
    return new DrawerScaffoldMenuControllerState();
  }
}

class DrawerScaffoldMenuControllerState
    extends State<DrawerScaffoldMenuController> {
  MenuController menuController;

  @override
  void initState() {
    super.initState();

    menuController = getMenuController(context);
    menuController.addListener(_onMenuControllerChange);
  }

  @override
  void dispose() {
    menuController.removeListener(_onMenuControllerChange);
    super.dispose();
  }

  getMenuController(BuildContext context) {
    final scaffoldState =
        context.ancestorStateOfType(new TypeMatcher<_DrawerScaffoldState>())
            as _DrawerScaffoldState;
    return scaffoldState.menuController;
  }

  _onMenuControllerChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, getMenuController(context));
  }
}

typedef Widget DrawerScaffoldBuilder(
    BuildContext context, MenuController menuController);

class Screen {
  final String title;
  final DecorationImage background;
  final WidgetBuilder contentBuilder;

  final Color color;

  final Color appBarColor;

  Screen(
      {this.title,
      this.background,
      this.contentBuilder,
      this.color,
      this.appBarColor});
}

class MenuController extends ChangeNotifier {
  final TickerProvider vsync;
  final AnimationController _animationController;
  MenuState state = MenuState.closed;

  MenuController({
    this.vsync,
  }) : _animationController = new AnimationController(vsync: vsync) {
    _animationController
      ..duration = const Duration(milliseconds: 250)
      ..addListener(() {
        notifyListeners();
      })
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.forward:
            state = MenuState.opening;
            break;
          case AnimationStatus.reverse:
            state = MenuState.closing;
            break;
          case AnimationStatus.completed:
            state = MenuState.open;
            break;
          case AnimationStatus.dismissed:
            state = MenuState.closed;
            break;
        }
        notifyListeners();
      });
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  get percentOpen {
    return _animationController.value;
  }

  open() {
    _animationController.forward();
  }

  close() {
    _animationController.reverse();
  }

  isOpen() {
    return state == MenuState.open;
  }

  toggle() {
    if (state == MenuState.open) {
      close();
    } else if (state == MenuState.closed) {
      open();
    }
  }
}

class DrawerScaffoldController {
  MenuController menuController;

  DrawerScaffoldController({this.open = false});

  bool open;
  ValueChanged<bool> onToggle;

  bool isOpen() => menuController.isOpen();
}

class AppBarProps {
  final Icon leadingIcon;
  final bool automaticallyImplyLeading;
  final List<Widget> actions;
  final Widget flexibleSpace;
  final PreferredSizeWidget bottom;
  final double elevation;
  final Brightness brightness;
  final IconThemeData iconTheme;
  final TextTheme textTheme;
  final bool primary;
  final bool centerTitle;
  final double titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final Color backgroundColor;
  final Widget title;

  AppBarProps(
      {this.leadingIcon = const Icon(Icons.menu),
      this.title,
      this.backgroundColor,
      this.automaticallyImplyLeading = true,
      this.actions,
      this.flexibleSpace,
      this.bottom,
      this.elevation = 0.0,
      this.brightness,
      this.iconTheme,
      this.textTheme,
      this.primary = true,
      this.centerTitle,
      this.titleSpacing = NavigationToolbar.kMiddleSpacing,
      this.toolbarOpacity = 1.0,
      this.bottomOpacity = 1.0});
}

enum MenuState {
  closed,
  opening,
  open,
  closing,
}

final menuScreenKey = new GlobalKey(debugLabel: 'MenuScreen');

class MenuView extends StatefulWidget {
  MenuView({
    this.menu,
    this.headerView,
    this.footerView,
    this.selectedItemId,
    this.onMenuItemSelected,
    this.color = Colors.white,
    this.background,
    this.animation = false,
    this.selectorColor,
    this.textStyle,
    this.padding = const EdgeInsets.only(left: 40.0, top: 15.0, bottom: 15.0),
    this.alignment = Alignment.center,
    this.itemBuilder,
  }) : super(key: menuScreenKey);

  final double maxSlideAmount = 275.0;

  final Menu menu;
  final String selectedItemId;
  final bool animation;
  final Function(String) onMenuItemSelected;

  final Widget headerView;
  final Widget footerView;
  final Function(BuildContext, MenuItem, bool) itemBuilder;
  final DecorationImage background;
  final Color color;

  final Color selectorColor;
  final TextStyle textStyle;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  _MenuViewState createState() => new _MenuViewState();
}

class _MenuViewState extends State<MenuView> with TickerProviderStateMixin {
  AnimationController titleAnimationController;
  double selectorYTop;
  double selectorYBottom;

  Color selectorColor;
  TextStyle textStyle;

  setSelectedRenderBox(RenderBox newRenderBox, bool useState) async {
    final newYTop = newRenderBox.localToGlobal(const Offset(0.0, 0.0)).dy;
    final newYBottom = newYTop + newRenderBox.size.height;
    if (newYTop != selectorYTop) {
//      setState(() {
      selectorYTop = newYTop;
      selectorYBottom = newYBottom;
//      });
    }
  }

  @override
  void initState() {
    super.initState();
    titleAnimationController = new AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    titleAnimationController.dispose();
    super.dispose();
  }

  createMenuTitle(MenuController menuController) {
    switch (menuController.state) {
      case MenuState.open:
      case MenuState.opening:
        titleAnimationController.forward();
        break;
      case MenuState.closed:
      case MenuState.closing:
        titleAnimationController.reverse();
        break;
    }

    return new AnimatedBuilder(
        animation: titleAnimationController,
        child: new OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.topLeft,
          child: new Padding(
            padding: const EdgeInsets.all(30.0),
            child: new Text(
              'Menu',
              style: new TextStyle(
                color: const Color(0x88444444),
                fontSize: 240.0,
                fontFamily: 'mermaid',
              ),
              textAlign: TextAlign.left,
              softWrap: false,
            ),
          ),
        ),
        builder: (BuildContext context, Widget child) {
          return new Transform(
            transform: new Matrix4.translationValues(
              250.0 * (1.0 - titleAnimationController.value) - 100.0,
              0.0,
              0.0,
            ),
            child: child,
          );
        });
  }

  createMenuItems(MenuController menuController) {
    final List<Widget> listItems = [];

    final animationIntervalDuration = 0.5;
    final perListItemDelay =
        menuController.state != MenuState.closing ? 0.15 : 0.0;

    final millis = menuController.state != MenuState.closing
        ? 150 * widget.menu.items.length
        : 600;
    final maxDuration = (widget.menu.items.length - 1) * perListItemDelay +
        animationIntervalDuration;
    for (var i = 0; i < widget.menu.items.length; ++i) {
      final animationIntervalStart = i * perListItemDelay;
      final animationIntervalEnd =
          animationIntervalStart + animationIntervalDuration;

      MenuItem item = widget.menu.items[i];

      final isSelected = item.id == widget.selectedItemId;

      Function onTap = () {
        widget.onMenuItemSelected(item.id);
        menuController.close();
      };
      Widget listItem = widget.itemBuilder == null
          ? _MenuListItem(
              title: item.title,
              isSelected: isSelected,
              selectorColor: selectorColor,
              textStyle: textStyle,
              menuView: widget,
              icon: item.icon == null ? null : Icon(item.icon),
              onTap: onTap,
              drawBorder: !widget.animation,
            )
          : InkWell(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: widget.itemBuilder(context, item, isSelected),
                  width: widget.maxSlideAmount,
                ),
              ),
              onTap: onTap,
            );

//      print("$maxDuration, $animationIntervalEnd");

      if (widget.animation)
        listItems.add(new AnimatedMenuListItem(
          menuState: menuController.state,
          isSelected: isSelected,
          duration: Duration(milliseconds: millis),
          curve: new Interval(animationIntervalStart / maxDuration,
              animationIntervalEnd / maxDuration,
              curve: Curves.easeOut),
          menuListItem: listItem,
        ));
      else {
        listItems.add(listItem);
      }
    }

    return Container(
      alignment: widget.alignment,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: listItems,
        ),
      ),
    );
  }

  Widget createDrawer(MenuController menuController) {
    List<Widget> widgets = [];
    if (widget.headerView != null) {
      widgets.add(Container(width: double.infinity, child: widget.headerView));
    }
    widgets.add(Expanded(
      child: createMenuItems(menuController),
      flex: 1,
    ));

    if (widget.footerView != null) {
      widgets.add(Container(
        width: double.infinity,
        child: widget.footerView,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      ));
    }
    return Transform(
      transform: new Matrix4.translationValues(
        0.0,
        MediaQuery.of(context).padding.top,
        0.0,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top,
        child: Column(
          children: widgets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    selectorColor = widget?.selectorColor ?? Theme.of(context).indicatorColor;
    textStyle = widget?.textStyle ??
        Theme.of(context).textTheme.subtitle2.copyWith(
            color: widget.color.computeLuminance() < 0.5
                ? Colors.white
                : Colors.black);
    return new DrawerScaffoldMenuController(
        builder: (BuildContext context, MenuController menuController) {
      var shouldRenderSelector = true;
      var actualSelectorYTop = selectorYTop;
      var actualSelectorYBottom = selectorYBottom;
      var selectorOpacity = 1.0;

      if (menuController.state == MenuState.closed ||
          menuController.state == MenuState.closing ||
          selectorYTop == null) {
        final RenderBox menuScreenRenderBox =
            context.findRenderObject() as RenderBox;

        if (menuScreenRenderBox != null) {
          final menuScreenHeight = menuScreenRenderBox.size.height;
          actualSelectorYTop = menuScreenHeight - 50.0;
          actualSelectorYBottom = menuScreenHeight;
          selectorOpacity = 0.0;
        } else {
          shouldRenderSelector = false;
        }
      }

      return new Container(
        width: double.infinity,
        height: double.infinity,
        decoration: new BoxDecoration(
          image: widget.background,
          color: widget.color,
        ),
        child: new Material(
          color: Colors.transparent,
          child: new Stack(
            children: [
              createDrawer(menuController),
              widget.animation && shouldRenderSelector
                  ? new ItemSelector(
                      selectorColor: selectorColor,
                      topY: actualSelectorYTop,
                      bottomY: actualSelectorYBottom,
                      opacity: selectorOpacity)
                  : new Container(),
            ],
          ),
        ),
      );
    });
  }
}

class ItemSelector extends ImplicitlyAnimatedWidget {
  final double topY;
  final double bottomY;
  final double opacity;

  final Color selectorColor;

  ItemSelector({
    this.topY,
    this.bottomY,
    this.opacity,
    this.selectorColor,
  }) : super(duration: const Duration(milliseconds: 250));

  @override
  _ItemSelectorState createState() => new _ItemSelectorState();
}

class _ItemSelectorState extends AnimatedWidgetBaseState<ItemSelector> {
  Tween<double> _topY;
  Tween<double> _bottomY;
  Tween<double> _opacity;

  @override
  void forEachTween(TweenVisitor visitor) {
    _topY = visitor(
      _topY,
      widget.topY,
      (dynamic value) => new Tween<double>(begin: value),
    );
    _bottomY = visitor(
      _bottomY,
      widget.bottomY,
      (dynamic value) => new Tween<double>(begin: value),
    );
    _opacity = visitor(
      _opacity,
      widget.opacity,
      (dynamic value) => new Tween<double>(begin: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Positioned(
      top: _topY.evaluate(animation),
      child: new Opacity(
        opacity: _opacity.evaluate(animation),
        child: new Container(
          width: 5.0,
          height: _bottomY.evaluate(animation) - _topY.evaluate(animation),
          color: widget.selectorColor,
        ),
      ),
    );
  }
}

class AnimatedMenuListItem extends ImplicitlyAnimatedWidget {
  final _MenuListItem menuListItem;
  final MenuState menuState;
  final bool isSelected;
  final Duration duration;

  AnimatedMenuListItem({
    this.menuListItem,
    this.menuState,
    this.isSelected,
    this.duration,
    curve,
  }) : super(duration: duration, curve: curve);

  @override
  _AnimatedMenuListItemState createState() => new _AnimatedMenuListItemState();
}

class _AnimatedMenuListItemState
    extends AnimatedWidgetBaseState<AnimatedMenuListItem> {
  final double closedSlidePosition = 200.0;
  final double openSlidePosition = 0.0;

  Tween<double> _translation;
  Tween<double> _opacity;

  updateSelectedRenderBox(bool useState) {
    final renderBox = context.findRenderObject() as RenderBox;
    if (renderBox != null && widget.isSelected) {
      (menuScreenKey.currentState as _MenuViewState)
          .setSelectedRenderBox(renderBox, useState);
    }
  }

  @override
  void forEachTween(TweenVisitor visitor) {
    var slide, opacity;

    switch (widget.menuState) {
      case MenuState.closed:
      case MenuState.closing:
        slide = closedSlidePosition;
        opacity = 0.0;
        break;
      case MenuState.open:
      case MenuState.opening:
        slide = openSlidePosition;
        opacity = 1.0;
        break;
    }

    _translation = visitor(
      _translation,
      slide,
      (dynamic value) => new Tween<double>(begin: value),
    );

    _opacity = visitor(
      _opacity,
      opacity,
      (dynamic value) => new Tween<double>(begin: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    updateSelectedRenderBox(false);

    return new Opacity(
      opacity: _opacity.evaluate(animation),
      child: new Transform(
        transform: new Matrix4.translationValues(
          0.0,
          _translation.evaluate(animation),
          0.0,
        ),
        child: widget.menuListItem,
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool drawBorder;
  final Function() onTap;
  final Color selectorColor;
  final TextStyle textStyle;
  final MenuView menuView;
  final Widget icon;

  _MenuListItem(
      {this.title,
      this.isSelected,
      this.onTap,
      this.menuView,
      @required this.textStyle,
      @required this.selectorColor,
      this.icon,
      this.drawBorder});

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyle =
        textStyle.copyWith(color: isSelected ? selectorColor : textStyle.color);

    List<Widget> children = [];
    if (icon != null)
      children.add(Padding(
        padding: EdgeInsets.only(right: 12),
        child: IconTheme(
            data: IconThemeData(color: _textStyle.color), child: icon),
      ));
    children.add(
      Expanded(
        child: new Text(
          title,
          style: _textStyle,
        ),
        flex: 1,
      ),
    );
    return new InkWell(
      splashColor: const Color(0x44000000),
      onTap: isSelected ? null : onTap,
      child: Container(
        width: double.infinity,
        decoration: drawBorder
            ? ShapeDecoration(
                shape: Border(
                  left: BorderSide(
                      color: isSelected ? selectorColor : Colors.transparent,
                      width: 5.0),
                ),
              )
            : null,
        child: new Padding(
          padding: menuView.padding,
          child: Row(
            children: children,
          ),
        ),
      ),
    );
  }
}

class Menu {
  final List<MenuItem> items;

  Menu({
    this.items,
  });
}

class MenuItem {
  final String id;
  final String title;
  final IconData icon;

  MenuItem({
    this.id,
    this.title,
    this.icon,
  });
}

class Utils {
  static double fixed(double value, int decimal) {
    int fac = pow(10, decimal);
    return (value * fac).round() / fac;
  }
}
