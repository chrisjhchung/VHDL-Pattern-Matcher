## COMP3211 Assignment

### Overview

For this project, we will be using a KMP algorithm for pattern matching in strings. This algorithm was selected due to its simplicity and effectiveness for handling overlapping patterns. 

For this program to work, there are two files that are needed:

1. string.txt
2. patterns.txt

string.txt contains the string that will be searched. It should only have one line and can only consist of alphanumeric characters (a-z,0-9). There is an assumption that there will be no capital letters (This case might be handled later)

patterns.txt contains a list of patterns that will be used. There can be up to 8 lines, where each line corresponds to one pattern. Each pattern can only have up to 16 characters. There is no validation, so the assumption is that this will always be the case. 

These two files must be placed inside: `COMP3211-Assignment/COMP3211-Assignment.sim/sim_1/behav/xsim`, otherwise the program won't be able to find it.

### Waveform

The waveform should be colour coded so that it is easy to see which signals come from each file. At present the style guide is as follows:

- White: Clock and reset signals
- Light blue: Test bench / I/O signals
- Green: Processor signals

