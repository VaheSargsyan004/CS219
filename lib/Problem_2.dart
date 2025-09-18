class Problem_2 {
  int sumNested(dynamic obj) {
    return switch (obj) {
      int n => n,
      double d => d.floor(),
      String s => sumAscii(s),
      List l => sumSpecialList(l),
      Map m => sumMap(m),
      (var a, var b) => sumPair((a, b)),
      (first: var c, second: var d) => sumPair((first: c, second: d)),
      _ => 0
    };
  }

  int sumPair(dynamic record) {
    return switch (record) {
      (var a, var b) => sumNested(a) + sumNested(b),
      (first: var c, second: var d) => sumNested(c) + sumNested(d),
      _ => 0
    };
  }

  int sumAscii(String s) {
    int total = 0;
    for (var rune in s.runes) {
      total += switch (rune) {
        >= 0 && <= 127 => rune,
        _ => 0
      };
    }
    return total;
  }

  int sumSpecialList(List<dynamic> l) {
    int total = 0;
    for (var e in l) {
      total += sumNested(e);
    }
    return total;
  }

  int sumMap(Map m) {
    int total = 0;
    for (var v in m.values) {
      total += sumNested(v);
    }
    return total;
  }

// This function prints breakdowns like the expected output
  String explain(dynamic obj) {
    return switch (obj) {
      int n => "$n → $n",
      double d => "$d → ${d.floor()}",
      String s =>
      '"$s" → ${s.runes.map((r) => r).join(" + ")} = ${sumAscii(s)}',
      List l =>
      "$l → ${l.map(sumNested).join(" + ")} = ${sumSpecialList(l)}",
      Map m =>
      "${m} → ${m.values.map(sumNested).join(" + ")} = ${sumMap(m)}",
      (var a, var b) =>
      "($a, $b) → ${sumNested(a)} + ${sumNested(b)} = ${sumPair((a, b))}",
      (first: var f, second: var s) =>
      "(first: $f, second: $s) → ${sumNested(f)} + ${sumNested(s)} = ${sumPair(
          (first: f, second: s))}",
      _ => "$obj → 0"
    };
  }

  void main() {
    final data = [
      1,
      [2, 3, 4],
      {'a': 5, 'b': ["ab", 7]},
      [],
      {},
      "lk",
      (first: 8, second: "c"),
      {'c': (first: 10, second: ["xy", 12])},
      "z",
      13.5,
      [14, {'d': 15, 'e': (first: "p", second: 17)}],
    ];

    int total = 0;
    for (var item in data) {
      print(explain(item));
      total += sumNested(item);
    }
    print("Total sum = $total");
  }
}