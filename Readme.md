# Introduction
A simple 8086 disassembler made for Casey Muratori's course over at [Computer, Enhance!](https://www.computerenhance.com/)
This is made for educational purposes, and probably should not be used for an actual production environment.

Made with [Odin](https://odin-lang.org/)

# Building
Just run this following command with Odin installed

``` odin
odin build .
```

Then run the program by passing the name of your assembly file
```
./8086.exe asm/listing_38
```

This will produce this following output
> Managed to decode 35317.586 instructions /second

# License
This repository is licensed under [MIT License.](./license.md)