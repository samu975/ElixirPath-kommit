# introduction to elixir and functional programming

## What is elixir ?

# Elixir is a functional, concurrent, general-purpose programming language that runs on the BEAM virtual machine which is also used to implement the Erlang programming language. Elixir builds on top of Erlang and shares the same abstractions for building distributed, fault-tolerant applications.

## Imperactive vs declarative programming

# Declarative: Describes what the code does. When you want to use the code in multiple places, declarative functions are easy to use and useful in these cases.

```Javascript
const arr = [2, 4, 6]
const arraySum = arrayReducer(arr)
console.log(`The sum is ${arraySum}`)
// The sum is 12
```

# Imperactive: Describes how the code does what it does.

```Javascript
const arr = [2, 4, 6]
let acc = 0
for (let i = 0; i < arr.length; i++){
  acc += arr[i]
}
console.log(`The sum is ${acc}`)
// The sum is 12
```

# Both codes do the same thing only the first is based on doing things and the second is based on how to do things. Elixir is a declarative language.
## Functional Programming Fundamentals

# Functional programming tries to create pure functions as much as possible. A function is pure when it receives certain values and these values do not change we always get the same results, and the function has no side effects.

## Bases of Functional Programming

# Separation: keeping functions small. Do one thing at once and doing well.

# Composition: write functions that return inputs for other functions.

# immutability: "The real constant is change. Mutation hides change. Hidden change manifests chaos. Therefore, the wise embrace history."

# Memoization: Memoization is an optimization technique used primarily to speed up computer programs by caching the results of expensive function calls and returning the cached result when the same inputs occur again.

# Higher Order Functions: is considered a higher order function when it takes one or more functions as parameters or when it returns a function as a result.

# Currying: "is the technique of translating the evaluation of a function that takes multiple arguments (or a tuple of arguments) into the evaluation of a sequence of functions, each with only one argument"
