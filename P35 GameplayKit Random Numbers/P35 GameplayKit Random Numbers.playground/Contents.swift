import GameplayKit
import UIKit

// produces a number between -2,147,483,648 and 2,147,483,647
GKRandomSource.sharedRandom().nextInt()
GKRandomSource.sharedRandom().nextInt(upperBound: 6)

let arc4 = GKARC4RandomSource()
arc4.dropValues(1024) // drops the first 1024 numbers
arc4.nextInt(upperBound: 20)

// GKLinearCongruentialRandomSource: has high performance but the lowest randomness
let linear = GKLinearCongruentialRandomSource()
linear.nextInt(upperBound: 100)

// GKMersenneTwisterRandomSource: has high randomness but the lowest performance
let mersenne = GKMersenneTwisterRandomSource()
mersenne.nextInt(upperBound: 100)

// GKARC4RandomSource: has good performance and good randomness
let arc = GKARC4RandomSource()
arc.nextInt(upperBound: 100)

// Built in 6 sided dice
let d6 = GKRandomDistribution.d6()
d6.nextInt()

// 20 sided dice!
let d20 = GKRandomDistribution.d20()
d20.nextInt()

// GKShuffledDistribution: Will go through every possible number before you see a repeat
let shuffled = GKShuffledDistribution.d6()
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())
print(shuffled.nextInt())

// GKGaussianDistribution: Causes the random numbers to bias towards the mean average of the range
let gaussian = GKGaussianDistribution(lowestValue: 1, highestValue: 10)
gaussian.nextInt()
gaussian.nextInt()
gaussian.nextInt()
gaussian.nextInt()
gaussian.nextInt()

let lotteryBalls = [Int](1...49)
let shuffledBalls = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lotteryBalls)
print(shuffledBalls[0])
print(shuffledBalls[1])
print(shuffledBalls[2])
print(shuffledBalls[3])
print(shuffledBalls[4])
print(shuffledBalls[5])


// Use seed to repeat the random numbers, for example across devices?
let fixedLotteryBalls = [Int](1...49)
let fixedShuffledBalls = GKMersenneTwisterRandomSource(seed: 1234).arrayByShufflingObjects(in: fixedLotteryBalls)
print(fixedShuffledBalls[0])
print(fixedShuffledBalls[1])
print(fixedShuffledBalls[2])
print(fixedShuffledBalls[3])
print(fixedShuffledBalls[4])
print(fixedShuffledBalls[5])

let balls = GKMersenneTwisterRandomSource(seed: 1234).arrayByShufflingObjects(in: fixedLotteryBalls)
balls[0]
balls[1]
balls[2]
balls[3]
balls[4]
balls[5]


