import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r2a_mobile/pages/Models/filter_model.dart';
import 'package:r2a_mobile/pages/bottom_nav_bar/chat/screens/callscreens/pickup/pickup_layout.dart';
import 'package:r2a_mobile/service/backend_service.dart';
import 'package:r2a_mobile/shared/custom_alerts.dart';
import 'package:r2a_mobile/shared_state/user.dart';

class FilterNewsFeed extends StatefulWidget {
  final Function(String filter) callbackfilter;
  final Function() refresh;
  final Filter selectedFilter;
  const FilterNewsFeed(
      {Key key, this.callbackfilter, this.selectedFilter, this.refresh})
      : super(key: key);
  @override
  _FilterNewsFeedState createState() => _FilterNewsFeedState();
}

class _FilterNewsFeedState extends State<FilterNewsFeed>
    with AutomaticKeepAliveClientMixin {
  List _statesList = List();
  List _districtsList = List();
  List _constituencyList = List();
  final List<DropdownMenuItem> _statusList = [];
  int filter;
  var state;
  var district;
  var constituency;
  var status = {};
  int selectedStatus;
  final List<DropdownMenuItem> states = [];
  final List<DropdownMenuItem> districts = [];
  final List<DropdownMenuItem> constituencies = [];
  bool reset = false;
  @override
  void initState() {
    super.initState();
    status = {0: "All Cases", 1: "Solved Cases", 2: "UnSolved Cases"};
    status.forEach((k, v) {
      _statusList.add(DropdownMenuItem(
        child: Text(v),
        value: k,
      ));
    });
    state = widget.selectedFilter.state;
    district = widget.selectedFilter.disctrict;
    constituency = widget.selectedFilter.constituency;
    selectedStatus = widget.selectedFilter.selectedStatus;
    Future.delayed(Duration.zero, () {
      getStateList();
    });
  }

  Future getStateList() async {
    try {
      final response = await BackendService.get('/auth/states/', {}, context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _statesList = _data["data"];
        if (mounted) {
          setState(() {
            _statesList.forEach((state) {
              states.add(DropdownMenuItem(
                child: Text(state['name']),
                value: state['id'],
              ));
            });
          });
        }
        if (widget.selectedFilter.state != null) {
          getDistrictList(widget.selectedFilter.state);
          if (mounted) {
            setState(() {
              district = widget.selectedFilter.disctrict;
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future getDistrictList(int stateId) async {
    try {
      final response =
          await BackendService.get('/auth/districts/$stateId', {}, context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _districtsList = _data["data"];
        if (mounted) {
          setState(() {
            _districtsList.forEach((district) {
              districts.add(DropdownMenuItem(
                child: Text(district['name']),
                value: district['id'],
              ));
            });
          });
        }
        if (widget.selectedFilter.disctrict != null) {
          getConstituencyList(widget.selectedFilter.disctrict);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future getConstituencyList(int districtId) async {
    try {
      final response = await BackendService.get(
          '/auth/constituencies/$districtId', {}, context);
      if (response.statusCode == 200) {
        var _data = jsonDecode(response.body);
        _constituencyList = _data["data"];
        if (mounted) {
          setState(() {
            _constituencyList.forEach((constituency) {
              districts.add(DropdownMenuItem(
                child: Text(constituency['name']),
                value: constituency['id'],
              ));
            });
            if (widget.selectedFilter.constituency != null) {
              constituency = widget.selectedFilter.constituency;
            }
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: true);
    super.build(context);
    return PickupLayout(
      userId: userState.id,
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text("Filter"),
          actions: <Widget>[
            FlatButton(
              disabledTextColor: Theme.of(context).textTheme.caption.color,
              onPressed: () {
                if (constituency != null) {
                  if (selectedStatus == 0) {
                    widget.callbackfilter(
                        'constituency=$constituency&status=null');
                  } else {
                    widget.callbackfilter(
                        'constituency=$constituency&status=$selectedStatus');
                  }
                  widget.callbackfilter(
                      'constituency=$constituency&status=$selectedStatus');
                  widget.selectedFilter.state = state;
                  widget.selectedFilter.disctrict = district;
                  widget.selectedFilter.constituency = constituency;
                  widget.selectedFilter.selectedStatus = selectedStatus;
                  Navigator.pop(context);
                } else if (district != null) {
                  if (selectedStatus == 0) {
                    widget.callbackfilter('district=$district&status=null');
                  } else {
                    widget.callbackfilter(
                        'district=$district&status=$selectedStatus');
                  }
                  widget.selectedFilter.state = state;
                  widget.selectedFilter.disctrict = district;
                  widget.selectedFilter.constituency = null;
                  widget.selectedFilter.selectedStatus = selectedStatus;
                  Navigator.pop(context);
                } else if (state != null) {
                  if (selectedStatus == 0) {
                    widget.callbackfilter('state=$state&status=null');
                  } else {
                    widget
                        .callbackfilter('state=$state&status=$selectedStatus');
                  }
                  widget.selectedFilter.state = state;
                  widget.selectedFilter.disctrict = null;
                  widget.selectedFilter.constituency = null;
                  widget.selectedFilter.selectedStatus = selectedStatus;
                  Navigator.pop(context);
                } else if (selectedStatus != null) {
                  if (selectedStatus == 0) {
                    widget.callbackfilter('status=null');
                  } else {
                    widget.callbackfilter('status=$selectedStatus');
                  }
                  Navigator.pop(context);
                } else if (reset == true) {
                  Navigator.pop(context);
                } else {
                  showDialog(
                      context: context,
                      builder: (_) => CustomAlertRoundedBox(
                            message: "Select any One",
                          ));
                }
              },
              child: Text(
                "Apply",
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).textTheme.headline1.color),
              ),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.03,
                        MediaQuery.of(context).size.width * 0.03,
                        0,
                        0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "State",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2.color),
                        ),
                        Container(
                          color:
                              Theme.of(context).inputDecorationTheme.fillColor,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              // iconEnabledColor: Theme.of(context).iconTheme.color,
                              isExpanded: true,
                              hint: Text(
                                'Select State',
                                style: TextStyle(
                                    color: Theme.of(context).textSelectionColor,
                                    fontSize: 15.0),
                              ),
                              value: state,
                              isDense: true,
                              items: _statesList.map((state) {
                                return DropdownMenuItem(
                                    value: state['id'],
                                    child: Text(state['name']));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  state = val;
                                  district = null;
                                  constituency = null;
                                  getDistrictList(state);
                                });
                              },
                            ),
                          ),
                        ),
                        Divider(
                          // color: Colors.white.withOpacity(0.5),
                          thickness: 0.5,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "District",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2.color),
                        ),
                        Container(
                          color:
                              Theme.of(context).inputDecorationTheme.fillColor,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              // iconEnabledColor: Colors.white,
                              isExpanded: true,
                              hint: Text(
                                'Select District',
                                style: TextStyle(
                                    color: Theme.of(context).textSelectionColor,
                                    fontSize: 15.0),
                              ),
                              value: district,
                              isDense: true,
                              items: _districtsList.map((district) {
                                return DropdownMenuItem(
                                    value: district['id'],
                                    child: Text(district['name']));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  district = val;
                                  constituency = null;
                                  getConstituencyList(district);
                                });
                              },
                            ),
                          ),
                        ),
                        Divider(
                          // color: Colors.white.withOpacity(0.5),
                          thickness: 0.5,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Constituency",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2.color),
                        ),
                        Container(
                          color:
                              Theme.of(context).inputDecorationTheme.fillColor,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              // iconEnabledColor: Colors.white,
                              isExpanded: true,
                              hint: Text(
                                'Select Constituency',
                                style: TextStyle(
                                    color: Theme.of(context).textSelectionColor,
                                    fontSize: 15.0),
                              ),
                              value: constituency,
                              isDense: true,
                              items: _constituencyList.map((constituency) {
                                return DropdownMenuItem(
                                    value: constituency['id'],
                                    child: Text(constituency['name']));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  constituency = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Divider(
                          // color: Colors.white.withOpacity(0.5),
                          thickness: 0.5,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Status",
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyText2.color),
                        ),
                        Container(
                          color:
                              Theme.of(context).inputDecorationTheme.fillColor,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              // iconEnabledColor: Colors.white,
                              isExpanded: true,
                              hint: Text(
                                'Select Status',
                                style: TextStyle(
                                    color: Theme.of(context).textSelectionColor,
                                    fontSize: 15.0),
                              ),
                              value: selectedStatus,
                              isDense: true,
                              items: _statusList,
                              onChanged: (val) {
                                setState(() {
                                  selectedStatus = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Divider(
                          // color: Colors.white.withOpacity(0.5),
                          thickness: 0.5,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: RaisedButton(
                              color: Colors.red[500],
                              child: Text(
                                "Reset",
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 18),
                              ),
                              onPressed: () {
                                setState(() {
                                  reset = true;
                                  widget.selectedFilter.constituency = null;
                                  widget.selectedFilter.disctrict = null;
                                  widget.selectedFilter.state = null;
                                  _districtsList = List();
                                  _constituencyList = List();
                                  selectedStatus = null;
                                  state = null;
                                  district = null;
                                  constituency = null;
                                  widget.callbackfilter(null);
                                  widget.refresh();
                                });
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30))),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
