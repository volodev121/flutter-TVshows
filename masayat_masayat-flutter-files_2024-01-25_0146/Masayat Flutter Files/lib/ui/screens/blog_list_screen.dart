import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/providers/app_config.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';
import 'blog_screen.dart';

class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  @override
  Widget build(BuildContext context) {
    var blog = Provider.of<AppConfig>(context, listen: false);
    return Scaffold(
      appBar:
          customAppBar(context, translate("Blogs_")) as PreferredSizeWidget?,
      body: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          itemCount: blog.appModel!.blogs!.length,
          itemBuilder: (context, index) {
            return Container(
              height: 325,
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Theme.of(context).primaryColorLight,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                          ),
                          child: Image.network(
                            "${APIData.blogImageUri}${blog.appModel!.blogs![index].image}",
                            height: 200,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            alignment: Alignment.center,
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "${blog.appModel!.blogs![index].title}",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            DateFormat.yMMMd().format(
                              DateTime.parse(
                                  "${blog.appModel!.blogs![index].updatedAt}"),
                            ),
                            style: TextStyle(fontSize: 13.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            "${blog.appModel!.blogs![index].detail}",
                            style: TextStyle(fontSize: 13.0),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.pushNamed(context, RoutePaths.blog,
                      arguments: BlogScreen(index)),
                ),
              ),
            );
          }),
    );
  }
}
