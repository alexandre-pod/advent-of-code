
## Run each day program

To execute the puzzle solvers, you need to go inside the folder and run the following command:

```swift
swift run Main -c release < input.txt
```

`-c release` make the program to be optimized.

The input text is given to the program through the standard input.

## Debugging

For debugging / performance analysis if it is not possible to configure the standard input (eg. using Instruments),
you can force a file to be used as standard input from the code itself.
To do that, add the following line in `main.swift` before the input is parsed by the program

```
freopen("input.txt", "r", stdin);
```
