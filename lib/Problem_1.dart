class Problem_1 {

  String numberToWords(int number) {
    if (number == 0) return "zero";

    const num_1to10 = [
      "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
    ];
    const num_10To20 = [
      "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
      "sixteen", "seventeen", "eighteen", "nineteen"
    ];
    const tens = [
      "",
      "",
      "twenty",
      "thirty",
      "forty",
      "fifty",
      "sixty",
      "seventy",
      "eighty",
      "ninety"
    ];

    String convert1To99(int n) {
      if (n < 10) {
        return num_1to10[n - 1];
      } else if (n < 20) {
        return num_10To20[n - 10];
      }

      int t = n ~/ 10;
      int u = n % 10;

      if (u == 0) {
        return tens[t];
      } else {
        return "${tens[t]} ${num_1to10[u-1]}";
      }
    }


    String convert1To999(int n) {
      if (n < 100) {
        return convert1To99(n);
      }

      int h = n ~/ 100;
      int rem = n % 100;

      if (rem == 0) {
        return "${num_1to10[h-1]} hundred";
      } else {
        return "${num_1to10[h-1]} hundred ${convert1To99(rem)}";
      }
    }

    // Break the numbers into millions, thousands and hundreds
    int millions = number ~/ 1000000;
    int thousands = (number % 1000000) ~/ 1000;
    int hundreds = number % 1000;

    List<String> parts = [];

    if (millions > 0) parts.add("${convert1To999(millions)} million");
    if (thousands > 0) parts.add("${convert1To999(thousands)} thousand");
    if (hundreds > 0) parts.add(convert1To999(hundreds));

    return parts.join(' ');
  }

  void main() {
    List<int> randomNumbers = [
      0, 7, 47, 189, 400, 18379, 1450890, 1000000, 88888888
    ];

    for (var num in randomNumbers) {
      print("$num -> ${numberToWords(num)}");
    }
  }
}