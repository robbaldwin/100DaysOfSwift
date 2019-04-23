// Challenge 8
//
// Milestone: Projects 22-24
//
// Rob Baldwin
//
import UIKit
import PlaygroundSupport

// SHOW ASSISTANT EDITOR!

// Setup Live View
let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
container.backgroundColor = .white
PlaygroundPage.current.liveView = container

// Challenge 1: Extend UIView so that it has a bounceOut(duration:) method that uses animation to scale its size down to 0.0001 over a specified number of seconds.

extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

let view = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
view.layer.cornerRadius = 100
view.backgroundColor = .blue
container.addSubview(view)
view.bounceOut(duration: 1.0)

// Challenge 2: Extend Int with a times() method that runs a closure as many times as the number is high. For example, 5.times { print("Hello!") } will print “Hello” five times.

extension Int {
    func times(action: () -> Void) {
        guard self > 0 else { return }
        for _ in 0 ..< self {
            action()
        }
    }
}

5.times {
    print("Hello!")
}

// Challange 3: Extend Array so that it has a mutating remove(item:) method. If the item exists more than once, it should remove only the first instance it finds. Tip: you will need to add the Comparable constraint to make this work!

extension Array where Element: Comparable {
    mutating func removeItem(item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}

var list = ["bird", "cat", "dog", "dog", "fish"]
list.removeItem(item: "dog")
print(list)



