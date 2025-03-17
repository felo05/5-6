import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? name;
  String? uuid;
  int? id;
  int? score;
  String? gender;
  Set<String> attended = {};
  int? level;
  String? khadem;
  String? momPhone;
  String? phone;
  String? dadPhone;
  String? address;
  DateTime? dateBirth;
  String? image;
  bool? isShamas;
  int? countKhoras;
  int? count2das;
  int? countTsb7a;
  int? count3shea;
  String? notes;

  User({
    this.name,
    this.uuid,
    this.image,
    this.countKhoras,
    this.count2das,
    this.id,
    this.score,
    this.countTsb7a,
    this.count3shea,
    this.notes,
    this.gender,
    this.attended = const {},
    this.level,
    this.address,
    this.dadPhone,
    this.dateBirth,
    this.isShamas,
    this.khadem,
    this.momPhone,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json, String uuid) {
    return User(
      name: json["name"],
      uuid: uuid,
      score: json["score"]??0,
      dateBirth: json["dateBirth"] != null
          ? (json["dateBirth"] as Timestamp).toDate()
          : null,
      gender: json["gender"],
      image: json["image"],
      khadem: json["khadem"],
      id: json["id"],
      countKhoras: json["countKhoras"]??0,
      count2das: json["count2das"]??0,
      countTsb7a: json["countTsb7a"]??0,
      count3shea: json["count3shea"]??0,
      notes: json["notes"],
      momPhone: json["momPhone"],
      phone: json["phone"],
      dadPhone: json["dadPhone"],
      address: json["address"],
      isShamas: json["isShamas"],
      level: json["class"],
      attended: json["attended"] == null
          ? {}
          : Set<String>.from(json["attended"].map((x) => x)),
    );
  }

  Map<String,dynamic> toJson(){
    return{
      "name":name,
      "uuid":uuid,
      "id":id,
      "score":score,
      "gender":gender,
      "countKhoras":countKhoras,
      "count2das":count2das,
      "countTsb7a":countTsb7a,
      "count3shea":count3shea,
      "notes":notes,
      "attended":attended,
      "class":level,
      "address":address,
      "dadPhone":dadPhone,
      "dateBirth":dateBirth,
      "image":image,
      "isShamas":isShamas,
      "khadem":khadem,
      "momPhone":momPhone,
      "phone":phone,
    };
  }

}
