// Project 24 Swift Strings
// Rob Baldwin

import Foundation

// Challange 1: Create a String extension that adds a withPrefix() method. If the string already contains the prefix it should return itself; if it doesn’t contain the prefix, it should return itself with the prefix added. For example: "pet".withPrefix("car") should return “carpet”.

extension String {
    func withPrefix(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return self }
        return String(prefix + self)
    }
}

print("pet".withPrefix("car")) // Adds car to the beginning of the String
print("carpet".withPrefix("car")) // Returns original String, as prefix already exists


// Challenge 2: Create a String extension that adds an isNumeric property that returns true if the string holds any sort of number. Tip: creating a Double from a String is a failable initializer.

extension String {
    func isNumeric() -> Bool {
        return Double(self) != nil
    }
}

"123".isNumeric() // true
"ABC".isNumeric() // false
"3.14".isNumeric() // true
"pi".isNumeric() // false

// Challenge 3: Create a String extension that adds a lines property that returns an array of all the lines in a string. So, “this\nis\na\ntest” should return an array with four elements.

extension String {
    func lines() -> [String] {
        return self.components(separatedBy: "\n")
    }
}

print("this\nis\na\ntest".lines())

let poem = """
Shall I compare thee to a summer’s day?
Thou art more lovely and more temperate:
Rough winds do shake the darling buds of May,
And summer’s lease hath all too short a date;
"""
print(poem.lines())
print("This text contains \(poem.lines().count) lines")
