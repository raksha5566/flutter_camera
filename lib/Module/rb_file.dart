import 'dart:convert';



class RbFile {
  int id;
  String name;
  int size;
  String path;
  String format;
  double progress;
  String fileurl;
  int status;
  String type;

  RbFile({this.path,this.type });
 
  factory RbFile.fromMap(Map<String, dynamic> json) => new RbFile(
    
      path: json["path"],
      type: json["type"],
       );

  Map<String, dynamic> toMap() => {
   
    "path": path,
    "type": type,
    
  };

  RbFile smFileFromJson(String string) {
    final jsonData = json.decode(string);
    return RbFile.fromMap(jsonData);
  }

  String smFileToJson(RbFile smFile) {
    final fileJson = smFile.toMap();
    return json.encode(fileJson);
  }
}
