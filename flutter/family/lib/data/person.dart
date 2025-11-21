enum Role {
  child(title: "เด็กเปรต"),
  parent(title: "ผู้ปกครอง");

  const Role({required this.title});
  final String title;
}

class Person {
  Person({
    required this.name,
    required this.age,
    required this.role,
    required this.limited_money,
  });
  String name;
  int age;
  Role role;
  int limited_money;
}

List<Person> data = [
  Person(name: "บอส", age: 20, role: Role.parent, limited_money: 0),
  Person(name: "Parn", age: 29, role: Role.child, limited_money: 0),
  Person(name: "Je", age: 21, role: Role.child, limited_money: 0),
  Person(name: "FF", age: 21, role: Role.child, limited_money: 0),
];
