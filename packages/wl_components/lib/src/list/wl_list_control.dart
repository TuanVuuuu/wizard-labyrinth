import 'package:flutter/cupertino.dart';
import 'package:wl_components/src/colors/wl_colors.dart';
import 'package:wl_components/src/fonts/wl_font.dart';
import 'package:wl_components/src/size/wl_padding.dart';
import 'package:wl_components/src/size/wl_radius.dart';

class WLListControl extends StatefulWidget {
  final List<Widget>? bodyContent;

  final Future<void> Function()? onRefresh;
  final Future<bool> Function()? onLoadMore;
  final bool hasMoreData;
  final Color? refreshIndicatorColor;
  final double contentSpacing;
  final EdgeInsets contentPadding;
  final bool addBottomSafeArea;
  final ScrollPhysics? physics;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;
  final double percentagePulled;
  final double loadMoreThreshold;
  final Widget Function(BuildContext, int)? itemBuilder;
  final int? itemCount;
  final List<Widget>? slivers;

  const WLListControl({
    super.key,
    this.scrollController,
    this.bodyContent,
    this.itemBuilder,
    this.itemCount,
    this.onRefresh,
    this.onLoadMore,
    this.hasMoreData = true,
    this.refreshIndicatorColor,
    this.contentSpacing = 0,
    this.contentPadding = EdgeInsets.zero,
    this.addBottomSafeArea = true,
    this.physics,
    this.backgroundColor,
    this.refreshTriggerPullDistance = 100.0,
    this.refreshIndicatorExtent = 60.0,
    this.percentagePulled = 0.2,
    this.loadMoreThreshold = 200.0,
    this.slivers,
  }) : assert(
         bodyContent != null ||
             (itemBuilder != null && itemCount != null) ||
             slivers != null,
         'Either bodyContent or both itemBuilder and itemCount must be provided',
       );

  @override
  State<WLListControl> createState() => _WLListControlState();
}

class _WLListControlState extends State<WLListControl> {
  bool _isLoadingMore = false;
  bool _canLoadMore = true;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WLListControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateCanLoadMore(oldWidget);
  }

  // Khi refresh list mà không sử dụng oneRefresh thì sẽ không thể reset lại _canLoadMore
  // Cần kiểm tra khi danh sách thay đổi thì sẽ reset lại _canLoadMore để có thể load more lại.
  void updateCanLoadMore(WLListControl oldWidget) {
    final itemCountChanged =
        oldWidget.itemCount != widget.itemCount && widget.itemCount != 0;
    final bodyContentChanged =
        oldWidget.bodyContent != widget.bodyContent &&
        (widget.bodyContent?.isNotEmpty ?? false);

    if (itemCountChanged || bodyContentChanged) {
      _canLoadMore = true;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    if (currentScroll > 0 &&
        currentScroll >= (maxScroll - widget.loadMoreThreshold) &&
        !_isLoadingMore &&
        _canLoadMore &&
        widget.hasMoreData &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !widget.hasMoreData || !_canLoadMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final bool hasMore = await widget.onLoadMore?.call() ?? false;

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        _canLoadMore = hasMore;
      });
    }
  }

  Future<void> _onRefresh() async {
    _canLoadMore = true;
    await widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _buildRefreshableContent(context);
  }

  Widget _buildRefreshableContent(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics:
          widget.physics ??
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        CupertinoSliverRefreshControl(
          refreshTriggerPullDistance: widget.refreshTriggerPullDistance,
          refreshIndicatorExtent: widget.refreshIndicatorExtent,
          onRefresh: _onRefresh,
          builder: _buildRefreshIndicator,
        ),
        ...widget.slivers ?? [],
        if (widget.bodyContent != null ||
            (widget.itemBuilder != null && widget.itemCount != null))
          _buildBodyContent(),
      ],
    );
  }

  SliverPadding _buildBodyContent() {
    final itemBuilder = widget.itemBuilder;
    final itemCount = widget.itemCount;
    if (itemBuilder != null && itemCount != null) {
      return SliverPadding(
        padding: widget.contentPadding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildIndexedItem(
              context,
              itemBuilder,
              itemCount,
              index,
            ),
            childCount: itemCount,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: widget.contentPadding,
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ..._spacedBody(widget.bodyContent ?? const []),
          if (widget.onLoadMore != null && _isLoadingMore)
            _buildLoadMoreIndicator(),
        ]),
      ),
    );
  }

  Widget _buildIndexedItem(
    BuildContext context,
    Widget Function(BuildContext, int) itemBuilder,
    int itemCount,
    int index,
  ) {
    final item = itemBuilder(context, index);
    if (index == itemCount - 1 &&
        widget.onLoadMore != null &&
        _isLoadingMore) {
      return Column(
        children: [
          item,
          _buildLoadMoreIndicator(),
        ],
      );
    }
    return item;
  }

  List<Widget> _spacedBody(List<Widget> bodyContent) {
    if (bodyContent.isEmpty) {
      return bodyContent;
    }
    final spaced = <Widget>[];
    for (var i = 0; i < bodyContent.length; i++) {
      if (i > 0) {
        spaced.add(SizedBox(height: widget.contentSpacing));
      }
      spaced.add(bodyContent[i]);
    }
    return spaced;
  }

  Widget _buildRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    final double percentagePulled = pulledExtent / refreshTriggerPullDistance;

    double size;
    if (refreshState == RefreshIndicatorMode.refresh ||
        refreshState == RefreshIndicatorMode.armed) {
      size = 10.0;
    } else {
      size = 10.0 * percentagePulled.clamp(0.0, 1.0);
    }

    final bool showSpinner =
        percentagePulled > widget.percentagePulled ||
        refreshState == RefreshIndicatorMode.refresh ||
        refreshState == RefreshIndicatorMode.armed;

    return Center(
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(top: WLPadding.small),
        alignment: Alignment.center,
        child:
            showSpinner
                ? CupertinoActivityIndicator(
                  radius: size,
                  color: widget.refreshIndicatorColor ?? WLColors.primary(),
                )
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!_canLoadMore || !widget.hasMoreData) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            'No more data',
            style: WLFont.normal,
          ),
        ),
      );
    }

    return SizedBox(
      height: 60,
      child: Center(
        child:
            _isLoadingMore
                ? CupertinoActivityIndicator(
                  radius: WLRadius.normal,
                  color: widget.refreshIndicatorColor ?? WLColors.primary(),
                )
                : const SizedBox.shrink(),
      ),
    );
  }
}
