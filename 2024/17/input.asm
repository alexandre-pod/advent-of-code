2,4, // bst §4
1,1, // bxl 1
7,5, // cdv §5
4,7, // bxc
1,4, // bxl 4
0,3, // adv §3
5,5, // out §5
3,   // jnz
0


repeat {
    b = a % 8 // bst §4
    b = b ^ 1 // bxl 1
    c = a >> b // cdv §5
    b = b ^ c  // bxc
    b = b ^ 4 // bxl 4
    // a = a / (pow(2, 3)) // adv §3
    a = a >> 3
    output.add(b) // out §5

//    a = 2^a

} while a != 0 // jnz

first output
var a = a
var b = 0
var c = 0

repeat {
    b = (a % 8) ^ 1
    c = a >> b
    b = b ^ c ^ 4
    a = a >> 3
    output.add(b)
} while a != 0

/*
b = 2
--> (a%8) ^ 1 ^ (a >> (a%8 ^ 1)) ^ 4 = 2
--> (a%8) ^ (a >> (a%8 ^ 1)) ^ 4 = 3
--> (a%8) ^ (a >> (a%8 ^ 1)) = 7
--> [(a & 0xFF) ^ (a >> (a & 0xFF ^ 1)) ] & 0xFF = 7

a = a & 0xFFFFF00 + a0

 (a0 ^ a >> (a0 ^ 1)) & 0xFF = 7

 round 2:
 b & 0xFF = 2 (expected output)







 16 * 3 = 48

 max size of input
 000000000000000000000000000000000000000000000000
 012012012012012012012012012012012012012012012012
  16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1

 round 16:

 b = a16 ^ 1
 c = a >> b
 output = b ^ c ^ 4
 output = 0 % 8

 -> b^c = 4
 -> a16 = 5 = 0x101

 round 15:

 b = a15 ^ 1
 c = (5 << 3 + a15) >> b
 output = b ^ c ^ 4
 output = 3 % 8

 -> b ^ c = 3 ^ 4 = 7 [% 8]
 -> a15 ^ 1 ^ (5 << 3 + a15) >> (a15 ^ 1) = 7 % 8
 ->



-> 16 rounds
 2,4,1,1,7,5,4,7,1,4,0,3,5,5,3,0

*/




