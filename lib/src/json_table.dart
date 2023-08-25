import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:json_table/src/pagination_box.dart';

import 'json_table_column.dart';
import 'table_column.dart';

typedef TableHeaderBuilder = Widget Function(String? header);
typedef TableCellBuilder = Widget Function(dynamic value);
typedef OnRowSelect = void Function(int index, dynamic map);

class JsonTable extends StatefulWidget {
  final List dataList;
  final TableHeaderBuilder? tableHeaderBuilder;
  final TableCellBuilder? tableCellBuilder;
  final List<JsonTableColumn>? columns;
  final bool showColumnToggle;
  final bool allowRowHighlight;
  final Color? rowHighlightColor;
  final int? paginationRowCount;
  final String filterTitle;
  final OnRowSelect? onRowSelect;
  final Color? fieldSelectorColor;
  // final ValueNotifier<Set<String?>>? returnFilterList;
  final Function(Set<String?>)? returnFilterList;

  const JsonTable(
    this.dataList, {
    Key? key,
    this.tableHeaderBuilder,
    this.tableCellBuilder,
    this.columns,
    this.showColumnToggle = false,
    this.allowRowHighlight = false,
    this.filterTitle = 'ADD FILTERS',
    this.rowHighlightColor,
    this.paginationRowCount,
    this.onRowSelect,
    this.fieldSelectorColor = Colors.blue,
    this.returnFilterList,
  }) : super(key: key);

  @override
  State createState() => _JsonTableState();
}

class _JsonTableState extends State<JsonTable> {
  Set<String?> headerList = {};
  Set<String?> filterHeaderList = {};
  int? highlightedRowIndex;
  int pageIndex = 0;
  int? paginationRowCount;
  int? pagesCount;
  List<Map>? data;
  Map<String?, String?> headerLabels = <String?, String?>{};
  Color? fieldSelectorColor;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    assert(widget.dataList.isNotEmpty);
    data = widget.dataList.cast<Map>();
    pageIndex = 0;
    if (_showPagination()) {
      paginationRowCount = math.min<int>(widget.paginationRowCount!, data!.length);
    }
    if (_showPagination()) {
      pagesCount = (data!.length / paginationRowCount!).ceil();
    }
    setHeaderList();
    fieldSelectorColor = widget.fieldSelectorColor;
  }

  @override
  void didUpdateWidget(JsonTable oldWidget) {
    if (oldWidget.dataList != widget.dataList) init();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          //Column Toggle Part
          if (widget.showColumnToggle) columnToggleWidget(),

          //DataTable Part
          dataTableWidget(),

          //Pagination Part
          if (_showPagination()) paginationWidget(),
        ],
      ),
    );
  }

  Widget columnToggleWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.filter_list),
        title: Text(
          "${widget.filterTitle} (${filterHeaderList.length})",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: <Widget>[
          Wrap(
            runSpacing: -12,
            direction: Axis.horizontal,
            children: <Widget>[
              for (String? header in headerList)
                Material(
                  // color: Colors.transparent,
                  child: InkWell(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          fillColor: MaterialStateProperty.all(fieldSelectorColor),
                          // activeColor: Colors.orange,
                          value: filterHeaderList.contains(header),
                          onChanged: null,
                        ),
                        Text(headerLabels[header]!),
                        const SizedBox(
                          width: 4.0,
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        if (filterHeaderList.contains(header)) {
                          filterHeaderList.remove(header);
                        } else {
                          filterHeaderList.add(header);
                        }

                        if (widget.returnFilterList != null) {
                          widget.returnFilterList!(filterHeaderList);
                        }
                      });
                    },
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget dataTableWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: (widget.columns != null)
          ? Row(
              children: widget.columns!
                  .where((item) => filterHeaderList.contains(item.field))
                  .map(
                    (item) => TableColumn(
                      item.label,
                      _getPaginatedData(),
                      widget.tableHeaderBuilder,
                      widget.tableCellBuilder,
                      item,
                      onRowTap,
                      highlightedRowIndex,
                      widget.allowRowHighlight,
                      widget.rowHighlightColor,
                    ),
                  )
                  .toList(),
            )
          : Row(
              children: filterHeaderList
                  .map(
                    (header) => TableColumn(
                      header,
                      _getPaginatedData(),
                      widget.tableHeaderBuilder,
                      widget.tableCellBuilder,
                      null,
                      onRowTap,
                      highlightedRowIndex,
                      widget.allowRowHighlight,
                      widget.rowHighlightColor,
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget paginationWidget() {
    return PaginationBox(
      pageIndex: pageIndex,
      pagesCount: pagesCount,
      onLeftButtonTap: _showLeftButton()
          ? () {
              setState(() {
                pageIndex--;
              });
            }
          : null,
      onRightButtonTap: showRightButton()
          ? () {
              setState(() {
                pageIndex++;
              });
            }
          : null,
    );
  }

  Set<String?> extractColumnHeaders() {
    var headers = <String?>{};
    if (widget.columns != null) {
      for (var item in widget.columns!) {
        headers.add(item.field);
        headerLabels[item.field] = item.label ?? item.field;
      }
    } else {
      for (var map in widget.dataList) {
        map.keys.forEach((key) {
          headers.add(key);
          headerLabels[key] = key;
        });
      }
    }
    return headers;
  }

  void setHeaderList() {
    var headerList = extractColumnHeaders();
    this.headerList = headerList;
    filterHeaderList.addAll(headerList);
  }

  onRowTap(int index, dynamic rowMap) {
    setState(() {
      if (highlightedRowIndex == index) {
        highlightedRowIndex = null;
      } else {
        highlightedRowIndex = index;
      }
    });
    if (widget.onRowSelect != null) widget.onRowSelect!(index, rowMap);
  }

  List? _getPaginatedData() {
    if (paginationRowCount != null) {
      final startIndex = pageIndex == 0 ? 0 : (pageIndex * paginationRowCount!);
      final endIndex = math.min((startIndex + paginationRowCount!), (data!.length - 1));
      if (endIndex == data!.length - 1) {
        return data!.sublist(startIndex, endIndex + 1).toList(growable: false);
      } else {
        return data!.sublist(startIndex, endIndex).toList(growable: false);
      }
    } else {
      return data;
    }
  }

  bool _showLeftButton() {
    return pageIndex > 0;
  }

  bool showRightButton() {
    return pageIndex < pagesCount! - 1;
  }

  bool _showPagination() {
    return widget.paginationRowCount != null;
  }
}
