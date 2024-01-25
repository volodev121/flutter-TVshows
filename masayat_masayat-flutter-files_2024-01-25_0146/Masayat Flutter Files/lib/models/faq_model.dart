class FaqModel{
  FaqModel({
    this.faqs,
  });

  List<Faq>? faqs;

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
    faqs: List<Faq>.from(json["faqs"].map((x) => Faq.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "faqs": List<dynamic>.from(faqs!.map((x) => x.toJson())),
  };
}

class Faq{
  Faq({
    this.id,
    this.question,
    this.answer,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  String? question;
  String? answer;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
    id: json["id"],
    question: json["question"],
    answer: json["answer"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "answer": answer,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
