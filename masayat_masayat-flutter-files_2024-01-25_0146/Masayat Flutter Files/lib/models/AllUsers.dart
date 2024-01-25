/// allusers : [{"name":"Admin","id":1,"email":"admin@mediacity.co.in"},{"name":"Alice Grater","id":4,"email":"alice@mediacity.co.in"},{"name":"Anne Smith","id":5,"email":"anne@mediacity.co.in"},{"name":"Info","id":6,"email":"info@mediacity.co.in"},{"name":"Devid Jones","id":8,"email":"devid@mediacity.co.in"},{"name":"John Doe","id":9,"email":"john@mediacity.co.in"},{"name":"Jack Brown","id":10,"email":"jack@mediacity.co.in"},{"name":"Milly Smith","id":11,"email":"milly@mediacity.co.in"},{"name":"Nick Jonas","id":12,"email":"producer@mediacity.co.in"},{"name":"NEERAJ","id":13,"email":"chechani.neeraj@gmail.com"},{"name":"ankit","id":14,"email":"ankit@gmail.com"},{"name":"thegr8dev","id":15,"email":"thegr8dev@gmail.com"}]

class AllUsers {
  AllUsers({
    this.allusers,
  });

  AllUsers.fromJson(dynamic json) {
    if (json['allusers'] != null) {
      allusers = [];
      json['allusers'].forEach((v) {
        allusers?.add(Allusers.fromJson(v));
      });
    }
  }
  List<Allusers>? allusers;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (allusers != null) {
      map['allusers'] = allusers?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// name : "Admin"
/// id : 1
/// email : "admin@mediacity.co.in"

class Allusers {
  Allusers({
    this.name,
    this.id,
    this.email,
  });

  Allusers.fromJson(dynamic json) {
    name = json['name'];
    id = json['id'];
    email = json['email'];
  }
  String? name;
  int? id;
  String? email;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['id'] = id;
    map['email'] = email;
    return map;
  }
}
