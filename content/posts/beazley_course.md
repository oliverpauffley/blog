+++
title = "Writing A Compiler In A Week"
author = ["Oliver Pauffley"]
date = 2025-05-15T10:35:00+01:00
draft = false
weight = 2003
+++

Writing a good compiler in a week is a pretty difficult task. Writing it in Haskell when you don't really know what you are doing is even tougher. But, thanks to the amazing course by [David Beazley](https://www.dabeaz.com/) I managed it! The code is [here](https://github.com/oliverpauffley/wabbit_compiler).

It was an amazing thing to take part in mainly just for the grind of just sitting down and coding at something for a week and by the end having a working project. Not that I just came up with everything myself. Dave does a great job of splitting up the work into mini projects so the compiler seems to just appear as you knock down the tasks. I also heavily borrowed the parsing/lexing sections from [cronokirby](https://github.com/cronokirby/haskell-in-haskell) which made that section significantly easier.

Out of all the code I think the section I'm most proud of is this:

```haskell
convertInstructions :: B.INSTRUCTION -> LLVMConverter (Maybe LLVMOperation)
convertInstructions (B.PUSH i) = push (InputI i) >> return Nothing
convertInstructions B.ADD = convertBin B.ADD
convertInstructions B.MUL = convertBin B.MUL
convertInstructions B.LT = convertBin B.LT
convertInstructions B.EQ = convertBin B.EQ
convertInstructions (B.LOADGLOBAL n) = convertLoad n Global
convertInstructions (B.LOADLOCAL n) = convertLoad n Local
convertInstructions (B.STOREGLOBAL n) = convertStore n Global
convertInstructions (B.STORELOCAL n) = convertStore n Local
convertInstructions (B.CALL name numArgs) = do
  args <- replicateM numArgs pop
  register <- getRegister
  push (InputR register)
  return $ Just (Call register name args)
convertInstructions B.PRINT = do
  val <- pop
  return $ Just (Print val)
convertInstructions B.RETURN = do
  val <- pop
  return $ Just (Return val)
convertInstructions (B.LOCAL n) = return $ Just (Allocate n)
convertInstructions (B.GOTO bl) = return $ Just (Goto bl)
convertInstructions (B.CBRANCH blT blF) = do
  r <- toIResult <$> pop
  return $ Just (Branch r blT blF)
convertBin :: B.INSTRUCTION -> LLVMConverter (Maybe LLVMOperation)
convertBin op = do
  right <- pop
  left <- pop
  register <- getRegister
  push (InputR register)
  return $ Just (BinOp (convertBinOp op) register left right)
```

What does it do? Well the `LLVMConvertor` is a state monad. It is responsible for two things.

1.  Tracking the current register we are going to use for some LLVM instructions.
2.  Keeping a stack of "interpreter" code that we need to covert into LLVM instructions.

We have already done some preliminary transformations to make this easier. So we should be starting from something like

```nil
PUSH 10
STOREGLOBAL "x"
LOADGLOBAL "x"
PUSH 1
ADD
STOREGLOBAL "x"
PUSH 23
PUSH 45
MUL
LOADGLOBAL "x"
ADD
PRINT
```

Which we need to transform into

```nil
    store i32 10, i32* @x
    %.0 = load i32, i32* @x
    %.1 = add i32 %.0, 1
    store i32 %.1, i32* @x
    %.2 = mul i32 23, 45
    %.3 = load i32, i32* @x
    %.4 = add i32 %.2, %.3
    call i32 (i32) @_print_int(i32 %.4)
    ret i32 0
```

The key parts here are the register names `%.0` and that we have turned something like

```nil
PUSH 23
PUSH 45
MUL
```

into

```nil
%.2 = mul i32 23, 45
```

So how does the haskell work?

```haskell
convertInstructions :: B.INSTRUCTION -> LLVMConverter (Maybe LLVMOperation)
```

Within the monad we are given an `INSTRUCTION` like "PUSH 10"
Well this needs to go into our stack within the state monad. So we just `push` onto the stack but we don't need to return a LLVM operation so the code for converting an interpreter instruction into an LLVM operation is:

```haskell
convertInstructions :: B.INSTRUCTION -> LLVMConverter (Maybe LLVMOperation)
convertInstructions (B.PUSH i) = push (InputI i) >> return Nothing
```

Or push the number onto our stack of instructions and return nothing

Then when we get to a `MUL` instruction we already have the two numbers on our stack of instructions so we need to "pop" those off, get a new register to assign our result to and then return the operation. Getting a new register looks like this:

```haskell
-- | gets a new register to store values and increments the counter for the next call
getRegister :: LLVMConverter IResult
getRegister = do
  LLVMState {..} <- get
  put $ LLVMState (succ _registerValue) _stack
  return _registerValue
```

So we get the current state of our register value, get it's successor with `succ` and update the value in the state. And converting an binary operation is just

```haskell
convertBin :: B.INSTRUCTION -> LLVMConverter (Maybe LLVMOperation)
convertBin op = do
  right <- pop
  left <- pop
  register <- getRegister
  push (InputR register)
  return $ Just (BinOp (convertBinOp op) register left right)
```

Note that we need to keep track of the registers in the stack which is what the line `push (InputR register)` is doing.

I still have lots of do on this compiler and I learnt so much during the course that I would really like to just start again with the knowledge that I have now. Overall I highly recommend taking one of David's courses.
