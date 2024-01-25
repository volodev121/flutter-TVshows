import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/datum.dart';
import '/models/episode.dart';
import 'package:http/http.dart' as http;

class WishListView extends StatefulWidget {
  WishListView(this.videoDetail);

  final Datum? videoDetail;

  @override
  _WishListViewState createState() => _WishListViewState();
}

class _WishListViewState extends State<WishListView> {
  bool checkWishlist = false;
  bool _visible = false;

  checkWishList(vType, id) async {
    var res;
    if (vType == DatumType.M) {
      final response = await http.get(
          Uri.parse(
              "${APIData.checkWatchlistMovie}$id?secret=" + APIData.secretKey),
          headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        res = json.decode(response.body);
        if (res['wishlist'] == 1 || res['wishlist'] == "1") {
          setState(() {
            checkWishlist = true;
            _visible = true;
          });
        } else {
          setState(() {
            checkWishlist = false;
            _visible = true;
          });
        }
      } else {
        throw "Can't check wishlist";
      }
    } else {
      final response = await http.get(
          Uri.parse(
              "${APIData.checkWatchlistSeason}$id?secret=" + APIData.secretKey),
          headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
      setState(() {
        res = json.decode(response.body);
      });
      if (response.statusCode == 200) {
        if (res['wishlist'] == 1 || res['wishlist'] == "1") {
          setState(() {
            _visible = true;
            checkWishlist = true;
          });
        } else {
          setState(() {
            checkWishlist = false;
            _visible = true;
          });
        }
      } else {
        throw "Can't check wishlist";
      }
    }
  }

  removeWishList(vType, id) async {
    if (vType == DatumType.M) {
      final response = await http.get(
          Uri.parse(
              "${APIData.removeWatchlistMovie}$id?secret=" + APIData.secretKey),
          headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
      if (response.statusCode == 200) {
        setState(() {
          checkWishlist = false;
        });
      } else {
        throw "Can't remove from wishlist";
      }
    } else {
      final response = await http.get(
          Uri.parse("${APIData.removeWatchlistSeason}$id?secret=" +
              APIData.secretKey),
          headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
      if (response.statusCode == 200) {
        setState(() {
          checkWishlist = false;
        });
      } else {
        throw "Can't remove from wishlist";
      }
    }
  }

  addWishList(vType, id) async {
    var type = vType == DatumType.T ? "S" : "M";
    final response = await http.post(Uri.parse("${APIData.addWatchlist}"),
        body: {"type": type, "id": '$id', "value": '1'},
        headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        checkWishlist = true;
      });
    } else {
      throw "Can't added to wishlist";
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _visible = false;
    });
    checkWishList(widget.videoDetail!.type, widget.videoDetail!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: _visible == false
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : Column(
                  children: [
                    checkWishlist == false
                        ? Icon(
                            Icons.add,
                            size: 30.0,
                          )
                        : Icon(
                            Icons.check,
                            color: activeDotColor,
                            size: 30.0,
                          ),
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                    ),
                    checkWishlist == true
                        ? Text(
                            translate("Wishlist_"),
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                              color: activeDotColor,
                            ),
                          )
                        : Text(
                            translate("Wishlist_"),
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.0,
                            ),
                          ),
                  ],
                ),
          onTap: () {
            if (checkWishlist == true) {
              removeWishList(widget.videoDetail!.type, widget.videoDetail!.id);
            } else {
              addWishList(widget.videoDetail!.type, widget.videoDetail!.id);
            }
          },
        ),
      ),
    );
  }
}
