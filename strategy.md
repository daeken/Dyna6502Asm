The strategy taken in Dyna6502Asm is fairly straightforward.  The original [6502asm](http://6502asm.com/) is pure interpretation based; it iterates over each instruction and executes it as necessary, in a large switch statement.  While this is simple and easy to work with, it's very slow.  To make this into a dynarec'd emulator, I did the following:

- Added a code accumulator to the global state.  This consists of the first PC (program counter) of the basic block (where it starts recompiling), and an array.
- Changed all of the cases in the interpreter switch to add onto that code accumulator, instead of actually executing.  E.g. if the original statement was `stackPush( regA );`, it'd turn into `emit('stackPush( regA );')`, which would add it to the code accumulator.
- I'd do this for all of the instructions in sequence, until a branch was reached.  At that point, I'd set the PC (in the accumulated code) to the branch target, and break out of my loop.
- At this point, I'd take all of the statements that were emitted, wrap them in `function() { ... }`, and eval the whole thing, to get a compiled function object back.
- I'd take that and add it to a code cache, which is an array of function objects, keyed by the first PC.
- From here, execution is trivial; when you want to start executing from a given PC, either because you just started execution or because you returned from one of these functions, you'd look at the code cache to see if the PC exists.  If it does, you simply call the function, otherwise you recompile the next block, cache it, then execute it.

If you've got any questions about how this works, shoot me an email at cody.brocious@gmail.com.
