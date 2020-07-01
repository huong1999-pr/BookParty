import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:party_booking/badges.dart';
import 'package:party_booking/data/network/model/account_response_model.dart';
import 'package:party_booking/data/network/model/base_response_model.dart';
import 'package:party_booking/data/network/model/list_categories_response_model.dart';
import 'package:party_booking/data/network/model/list_dishes_response_model.dart';
import 'package:party_booking/data/network/model/menu_model.dart';
import 'package:party_booking/data/network/service/app_api_service.dart';
import 'package:party_booking/res/assets.dart';
import 'package:party_booking/res/constants.dart';
import 'package:party_booking/screen/history_order_screen.dart';
import 'package:party_booking/screen/list_posts_screen.dart';
import 'package:party_booking/screen/login_screen.dart';
import 'package:party_booking/screen/main_screen/components/dish_cart.dart';
import 'package:party_booking/screen/modify_disk/modify_dish_screen.dart';
import 'package:party_booking/screen/map_screen.dart';
import 'package:party_booking/screen/profile_screen.dart';
import 'package:party_booking/widgets/common/utiu.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../about_us_screen.dart';

class MainScreen extends StatefulWidget {
  final AccountModel accountModel;
  final List<DishModel> listDishModel;
  final List<Category> listCategories;

  MainScreen(
      {@required this.accountModel,
      @required this.listCategories,
      this.listDishModel});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _fullNameUser = "PartyBooking";
  String _token = "";
  String _avatar = "";
  String _email = "";
  var _listMenuFiltered = List<MenuModel>();
  final _listDishOrigin = List<DishModel>();
  AccountModel _accountModel;
  String _searchText = "";
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle;
  int i = 0;
  final TextEditingController _filter = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _accountModel = widget.accountModel;
    _appBarTitle = Text(widget.accountModel.fullName);
    _fullNameUser = widget.accountModel.fullName;
    _avatar = widget.accountModel.avatar;
    _email = widget.accountModel.email;
    _initLayout();
    if (widget.listDishModel == null) {
      _getListDishes(where: 'initState');
    } else {
      _initListDishData(widget.listDishModel);
    }
    _initSearch();
  }

  void _initLayout() {
    _appBarTitle = Text(_accountModel.fullName);
    _fullNameUser = _accountModel.fullName;
    _avatar = _accountModel.avatar;
    _email = _accountModel.email;
  }

  void _initSearch() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
          _listMenuFiltered = _menuAllocation(_listDishOrigin);
        });
      } else {
        setState(() {
          _searchText = _filter.text;
        });
      }
    });
  }

  Future<void> _getListDishes({String where = ""}) async {
    print(where);
    print('_getListDishes');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(Constants.USER_TOKEN);

    var result = await AppApiService.create().getListDishes(token: _token);
    if (result.isSuccessful) {
      _initListDishData(result.body.listDishes);
      prefs.setString(Constants.LIST_DISH_MODEL_KEY,
          listDishesResponseModelToJson(result.body).toString());
    } else {
      BaseResponseModel model = BaseResponseModel.fromJson(result.error);
      UTiu.showToast(message: model.message, isFalse: true);
    }
  }

  void _initListDishData(List<DishModel> model) {
    setState(() {
      _listMenuFiltered.clear();
      _listDishOrigin.clear();
      _listMenuFiltered.addAll(_menuAllocation(model));
      _listDishOrigin.addAll(model);
    });
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = new TextField(
          controller: _filter,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text(_accountModel.fullName);
        _listMenuFiltered = _menuAllocation(_listDishOrigin);
        _filter.clear();
      }
    });
  }

  void _signOut() async {
    var result = await AppApiService.create().requestSignOut(token: _token);
    if (result.isSuccessful) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove(Constants.ACCOUNT_MODEL_KEY);
      prefs.remove(Constants.USER_TOKEN);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false);
    }
  }

  void _goToAddDish() async {
    bool result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => ModifyDishScreen()));
    if (result != null) {
      print("_goToAddDish: _getListDishes");
      _getListDishes(where: '_goToAddDish');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitle,
        actions: <Widget>[
          InkWell(onTap: _searchPressed, child: _searchIcon),
          _shoppingCartBadge(),
        ],
      ),
      floatingActionButton: buildFABAddNewDish(),
      drawer: _buildAppDrawer(),
      body: Flex(direction: Axis.vertical, children: [
        Expanded(
          child:
              RefreshIndicator(onRefresh:() => _getListDishes(where: 'onRefresh'), child: _buildList()),
        ),
      ]),
    );
  }

  Visibility buildFABAddNewDish() {
    bool isVisible =
        (_accountModel != null && _accountModel.role == Role.Staff.index);
    return Visibility(
      visible: isVisible,
      child: FloatingActionButton(
        onPressed: _goToAddDish,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text(
            _fullNameUser,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundImage: NetworkImage(_avatar),
            backgroundColor: Colors.transparent,
          ),
          accountEmail: Text(
            _email,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 15.0),
          ),
          onDetailsPressed: _goToProfile,
        ),
        _createDrawerItem(
            icon: Icons.home,
            text: 'Home',
            onTap: () {
              Navigator.pop(context);
            }),
        _createDrawerItem(
            icon: Icons.account_circle,
            text: 'Profile',
            onTap: _goToProfile),
        _createDrawerItem(
          icon: Icons.location_on,
          text: 'Address',
          onTap:

              () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => MapPage(),
    ),
    );
    }),


        _createDrawerItem(
            icon: Icons.history,
            text: 'My Ordered',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryOrderScreen(),
                ),
              );
            }),
        _createDrawerItem(
            icon: FontAwesomeIcons.solidNewspaper,
            text: 'News',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListPostsScreen(),
                ),
              );
            }),
        Divider(),
        _createDrawerItem(
            icon: FontAwesomeIcons.info,
            text: 'About Us',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutUsScreen()));
              //   Navigator.pop(profile);
            }),
        _createDrawerItem(
            icon: FontAwesomeIcons.signOutAlt, text: 'Logout', onTap: _signOut),
        Center(
          child: Text(
            'Version\nAlpha 1.0.0',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ));
  }

  Widget _buildList() {
    if (_searchText.isNotEmpty) {
      List<DishModel> tempList = new List();
      for (int i = 0; i < _listDishOrigin.length; i++) {
        if (_listDishOrigin[i]
            .name
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          tempList.add(_listDishOrigin[i]);
        }
      }
      setState(() {
        _listMenuFiltered = _menuAllocation(tempList);
      });
    } else {
      setState(() {
        _listMenuFiltered = _menuAllocation(_listDishOrigin);
      });
    }
    return _listMenuFiltered.isNotEmpty
        ? ListView.separated(
            separatorBuilder: (BuildContext context, int index) => Divider(),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            itemCount: _listMenuFiltered.length,
            itemBuilder: (BuildContext context, int index) {
              return _itemMenu(_listMenuFiltered[index]);
            })
        : Center(
            child: Lottie.asset(
              Assets.animBagError,
              repeat: true,
            ),
          );
  }

  Widget _itemMenu(MenuModel menuModel) {
    return Column(
      children: <Widget>[
        Container(
          height: 50,
          margin: EdgeInsets.only(bottom: 10),
          color: Colors.lightGreen,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(menuModel.menuName,
                  style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            ],
          ),
        ),
        _itemGridView(menuModel.listDish)
      ],
    );
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 28,
          ),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _itemGridView(List<DishModel> dishes) {
    return StaggeredGridView.countBuilder(
      scrollDirection: Axis.vertical,
      crossAxisCount: 2,
      itemCount: dishes.length,
      itemBuilder: (BuildContext context, int index) =>
          DishCard(dishModel: dishes[index], accountModel: widget.accountModel, getListDish: () {_getListDishes(where: 'itemBuilder');}),
      staggeredTileBuilder: (int index) => new StaggeredTile.fit(1),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      primary: false,
      shrinkWrap: true,
    );
  }

  List<MenuModel> _menuAllocation(List<DishModel> dishes) {
    List<Category> listCategories = widget.listCategories;
    var listMenu = List<MenuModel>();

    dishes.forEach((dish) {
      dish.categories.forEach((dishCategory) {
        listCategories.forEach((category) {
          if (dishCategory == category.name) {
            bool haveThisCate = false;
            listMenu.forEach((menu) {
              if (menu.menuName == category.name) {
                menu.listDish.add(dish);
                haveThisCate = true;
              }
            });
            if (!haveThisCate) {
              listMenu
                  .add(MenuModel(menuName: category.name, listDish: [dish]));
            }
          }
        });
      });
    });
    return listMenu;
  }

  Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .calculateTotalItem()
            .toString(),
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          }),
    );
  }

  _goToProfile(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          mAccountModel: _accountModel,
        ),
      ),
    );
  }
}
