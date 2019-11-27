# FlappyBird

Project for EE 371


Need to add the counter module for scorekeeping [X]
  - I implemented score keeping with the CollisionDetection module

CLOCK SPEEDS REQS:
  CollisionDetection module
    - needs to be clocked at the same rate as the pipes move across the screen
    - if clock to CollisionDetection is twice as fast as the clock moving the pipes then the score will increment twice
    
  bird module
    - needs a clock that is slow enough for user to be able to beat "gravity"
    - POSSIBLE ISSUE if the clock is TOO SLOW then spacebar press might be missed
      - POSSIBLE SOLUTION only lower bird every Xth clock cycle. This keeps a fast clock to register spacebar input but keeps the bird
        falling too fast
   
  pipes module
    - clock at same speed as CollisionDetection
    
  LFSR_10Bit module
    - clock faster than pipe but not at a multiple of pipes clock
    - also not a big deal. Randomness factor is not required
   
