; List of extensions
extensions
[
  matrix
  CSV
]

; List of global variables
globals
[
  Days ; Number of days in the simulation
  Bats ; Number of bats in the simulation
  Roosts ; Number of roosts
  p_die ; probability of being killed by a predator
  red_pop_extinct
  orange_pop_extinct
  yellow_pop_extinct
  green_pop_extinct
]

turtles-own
[
  relation ; Vector relationship with all other bats in the system
  age ; Age of the bat, in days (time steps)
  days-since-eat ; Days since the last time the bat has eaten
  mother ; The ID of bat's mother
  children ; Vector of bat's children's IDs
  decision ; Determines whether a bat's propensity to seek new (0) or familiar individuals (1).
  ; A decision value of 2 will be implemented for when bats adjust their strategy in life
  p_succ ; Probability of being successful finding food (age-dependent)
  fed? ; Boolean variable stating whether the bat received food or not
  roost-switch ; Vector or probability of roost switches given days since last switch
  last-switch ; Days since last switch
  donate_give ; Number of portions of food that can be given
  donate_need ; The amount of blood required for the day
  groom_give ; Proportion of time given to other bats
  threshold ; The amount of relationship score for a bat to settle in a roost
]

patches-own
[
  roost
  bat-count
]

; Setup environment and intialize variables
to setup
  clear-all ; Clear previous data
  reset-ticks ; Reset ticks to zero

  set p_die 0.0005 ; probability of being killed by a predator

  set red_pop_extinct False
  set orange_pop_extinct False
  set yellow_pop_extinct False
  set green_pop_extinct False

  ; Set number of days
  set Days 365 * 200

  ; Set the number of roosts (do NOT change unless changing the code below)
  set Roosts 12

  ; Code to individually mark patches' roost numbers
  let a 0 ; Used for roost number
  ask patch -4 3
  [
    set a a + 1 ; Updates roost number every 4th entry
    set roost a ; Marks roost number
    set pcolor black ; alternating colors by 4x4 groups of patches to show different roosts clearly
  ]
  ask patch -4 2
  [
    set roost a
    set pcolor black
  ]
  ask patch -3 3
  [
    set roost a
    set pcolor black
  ]
  ask patch -3 2
  [
    set roost a
    set pcolor black
  ]

  ask patch -2 3
  [
    set a a + 1
    set roost a
    set pcolor white
  ]
  ask patch -2 2
  [
    set roost a
    set pcolor white
  ]
  ask patch -1 3
  [
    set roost a
    set pcolor white
  ]
  ask patch -1 2
  [
    set roost a
    set pcolor white
  ]

  ask patch 0 3
  [
    set a a + 1
    set roost a
    set pcolor black
  ]
  ask patch 0 2
  [
    set roost a
    set pcolor black
  ]
  ask patch 1 3
  [
    set roost a
    set pcolor black
  ]
  ask patch 1 2
  [
    set roost a
    set pcolor black
  ]

  ask patch 2 3
  [
    set a a + 1
    set roost a
    set pcolor white
  ]
  ask patch 2 2
  [
    set roost a
    set pcolor white
  ]
  ask patch 3 3
  [
    set roost a
    set pcolor white
  ]
  ask patch 3 2
  [
    set roost a
    set pcolor white
  ]

  ask patch -4 1
  [
    set a a + 1
    set roost a
    set pcolor white
  ]
  ask patch -4 0
  [
    set roost a
    set pcolor white
  ]
  ask patch -3 1
  [
    set roost a
    set pcolor white
  ]
  ask patch -3 0
  [
    set roost a
    set pcolor white
  ]

  ask patch -2 1
  [
    set a a + 1
    set roost a
    set pcolor black
  ]
  ask patch -2 0
  [
    set roost a
    set pcolor black
  ]
  ask patch -1 1
  [
    set roost a
    set pcolor black
  ]
  ask patch -1 0
  [
    set roost a
    set pcolor black
  ]

  ask patch 0 1
  [
    set a a + 1
    set roost a
    set pcolor white
  ]
  ask patch 0 0
  [
    set roost a
    set pcolor white
  ]
  ask patch 1 1
  [
    set roost a
    set pcolor white
  ]
  ask patch 1 0
  [
    set roost a
    set pcolor white
  ]
  ask patch 2 1
  [
    set a a + 1
    set roost a
    set pcolor black
  ]
  ask patch 2 0
  [
    set roost a
    set pcolor black
  ]
  ask patch 3 1
  [
    set roost a
    set pcolor black
  ]
  ask patch 3 0
  [
    set roost a
    set pcolor black
  ]

  ask patch -4 -1
  [
    set a a + 1
    set roost a
    set pcolor black
  ]
  ask patch -4 -2
  [
    set roost a
    set pcolor black
  ]
  ask patch -3 -1
  [
    set roost a
    set pcolor black
  ]
  ask patch -3 -2
  [
    set roost a
    set pcolor black
  ]

  ask patch -2 -1
  [
    set a a + 1
    set roost a
    set pcolor white
  ]
  ask patch -2 -2
  [
    set roost a
    set pcolor white
  ]
  ask patch -1 -1
  [
    set roost a
    set pcolor white
  ]
  ask patch -1 -2
  [
    set roost a
    set pcolor white
  ]

  ask patch 0 -1
  [
    set a a + 1
    set roost a
    set pcolor black
  ]
  ask patch 0 -2
  [
    set roost a
    set pcolor black
  ]
  ask patch 1 -1
  [
    set roost a
    set pcolor black
  ]
  ask patch 1 -2
  [
    set roost a
    set pcolor black
  ]

  ask patch 2 -1
  [
    set a a + 1
    set roost a
    set pcolor white
  ]
  ask patch 2 -2
  [
    set roost a
    set pcolor white
  ]
  ask patch 3 -1
  [
    set roost a
    set pcolor white
  ]
  ask patch 3 -2
  [
    set roost a
    set pcolor white
  ]

  ; There are Bats bats in this simulation
  set Bats 100

  ; Create bats
  create-turtles Bats
  [
    setxy random-pxcor random-pycor ; Random starting patch
    set threshold 200 ; Threshold for settling in a roost
    move-to one-of patches ; Make sure they are on a patch
    set relation matrix:make-constant 1 100000 0 ; Vector relationship with all other bats in the system (100,000 is arbitrary)
    ; Set the relationships to be 25 for all existing bats at the start
    let i 0 ; Create index
    while [i < Bats]
    [ ; While we haven't looked eat all bats initially in the system
      matrix:set relation 0 i 25 ; Set their relationship to 25
      set i i + 1 ; And update the index
    ]
    set age round (random-normal (365 * 4) (365 / 2)) ; Age of the bat, in days (time steps)
    set days-since-eat 0 ; Days since the last time the bat has eaten
    set last-switch 0 ; Days since last roost switch
    ; Vector of roost switching probabilities
    set roost-switch matrix:from-row-list [[0.33868332	0.420528596	0.506737929	0.59242393	0.672852887	0.744388203	0.804994817	0.85422101	0.89281555	0.92222053	0.944125339	0.960164111	0.971757069	0.980057298]]
    set roost-switch matrix:get-row roost-switch 0
    ; Make half the bats have a focused or diversifying strategy
    ifelse who <  round(Bats / 4)
    [
      set color green
      set decision 0; Determines whether a bat's propensity to seek new (0) or familiar individuals (1).
                    ; A decision value of 2 will be implemented for when bats adjust their strategy in life
    ]
    [
      ifelse who < round(Bats / 2)
      [
        set color red
        set decision 1
      ]
      [
        ifelse who < round(Bats * 3 / 4)
        [
          set color yellow
          set decision 2
        ]
        [
          set color orange
          set decision 3
        ]
      ]
    ]
    set fed? 1 ; Boolean variable stating whether the bat received food or not
  ]
end

; The bats attempt to find food outside the safety of their nest
to feed
  let b random-float 1 ; generate random number
  set p_succ foraging / (1 + exp(-0.01 * (age - 500))) ; Determine the probability of a successful hunt
  ifelse b < p_succ
  [ ; If the bat found food
    set fed? TRUE ; Mark that the bat was fed
    set days-since-eat 0 ; Reset the days since eaten
    set donate_give 5 ; Reset the amount of food the bat can donate to 5 units
    set donate_need 0 ; Reset the amount of food the bat needs for donation to 0 units
  ]
  [ ; Otherwise, if the bat did not find food
    set fed? FALSE ; Mark that the bat did not feed
    set days-since-eat days-since-eat + 1 ; And increase the days since it last ate
    set donate_give 0 ; Reset the amount of food the bat can donate to 0 units
    set donate_need 3 ; Reset the amount of food the bat needs for donation to 3 units
  ]

  ; Determine whether the bat was killed while searching for food
  let c random-float 1 ; regenerate random number
  if c < p_die
  [ ; If the bat was found and killed
    let dead-who who ; Find the id of the bat dying
    ask turtles with [who != dead-who]
    [ ; Set all relations of other bats with this bat to 0
      matrix:set relation 0 dead-who 0
    ]
    die ; And kill the bat
  ]
end

; All non-juvenile bats move, returning to a new or different roost, this section made with the consultation and guidance of ChatGPT
to move
  ; For all independent bats greater than two years of age
  if age >= (365 * 2)
  [ ; If older than two years old
    if count turtles > (Roosts * limit)
    [
      die
    ]
    let p random-float 1 ; Probability of roost-switch
    let roost-switch-prob item last-switch roost-switch ; The probability of a roost switch
    ifelse p > roost-switch-prob
    [ ; If a roost switch isn't supposed to occur, move to the last roost
      move-to one-of patches with ([roost = [roost] of myself])
      set last-switch last-switch + 1 ; And add 1 day to days since last switch
    ]
    [ ; If there is a roost switch
      set last-switch 0 ; reset the days since last roost switch
      ifelse social-pref? = False
      [ ; If there is no social preference
        move-to one-of patches with ([roost != [roost] of myself and bat-count <= limit]) ; Move to a different patch
      ]
      [ ; If there is social preference
        let found? False ; Marker for whether we have found a roost
        let i 0
        let options [1 2 3 4 5 6 7 8 9 10 11 12] ; Create list of potential options already checked
        set options remove roost options ; Mark that the bat can't return to the same roost
        while [i < (Roosts - 2) and found? = False]
        [ ; While we haven't found a roost
          let index random length options ; Choose a random number
          let random-roost item index options ; Pick a roost
          set options remove random-roost options ; Add this to the places already checked
          if any? turtles with [random-roost = (i + 1)]
          [ ; If there are any bats present in the checked roost
            let bat-count-local count turtles with [random-roost = (i + 1)] ; Count the number of bats
            if bat-count-local < limit
            [ ; If there is an acceptable amount of bats
              let matching-bats turtles with [roost = (i + 1)] ; Find all turtles in theat roost
              set matching-bats [who] of matching-bats ; And store their id's
              let j 0 ; Create another index
              let relation-total 0 ; Initialize
              while [j < (length matching-bats) or relation-total < threshold]
              [ ; And while we have't looked at every matching bat
                let current-bat item j matching-bats ; Isolate the bat
                let row1 matrix:get-row relation 0 ; Get the relationship matrix
                let current-relation item current-bat row1 ; Find the focal bat's relationship
                set relation-total relation-total + current-relation ; Update the total relationship score for this roost
                set j j + 1 ; And update the index
              ]
              if relation-total >= threshold
              [ ; If this is acceptable amount of relation
                set found? True
              ]
            ]
          ]
          set i i + 1 ; Update index
        ]
        ifelse found? = False
        [ ; If we haven't found a suitable place to go
          move-to one-of patches with ([roost != [roost] of myself]) ; Move to a random roost
        ]
        [ ; If we have
          move-to one-of patches with ([roost = (i + 1)]) ; Move to the chosen roost
        ]
      ]
    ]
  ]
end

; Move all the juvenile bats to a new location based on mother's movement
to move-children
  ; For all dependent bats less than two years old
  if (age < (365 * 2))
  [ ; If less than two years old
    if count turtles > (Roosts * limit)
    [
      die
    ]
    ifelse (any? turtles with [who = [mother] of myself])
    [ ; and mother is still alive, the bat moves to where its mother is
      move-to one-of turtles with ([who = [mother] of myself])
    ]
    [ ; Otherwise, move as normal, this section made with the consultation and guidance of ChatGPT
      if count turtles > (Roosts * limit)
      [
        die
      ]
      let p random-float 1 ; Probability of roost-switch
      let roost-switch-prob item last-switch roost-switch ; The probability of a roost switch
      ifelse p > roost-switch-prob
      [ ; If a roost switch isn't supposed to occur, move to the last roost
        move-to one-of patches with ([roost = [roost] of myself])
        set last-switch last-switch + 1 ; And add 1 day to days since last switch
      ]
      [ ; If there is a roost switch
        set last-switch 0 ; reset the days since last roost switch
        ifelse social-pref? = False
        [ ; If there is no social preference
          move-to one-of patches with ([roost != [roost] of myself and bat-count <= limit]) ; Move to a different patch
        ]
        [ ; If there is social preference
          let found? False ; Marker for whether we have found a roost
          let i 0
          let options [1 2 3 4 5 6 7 8 9 10 11 12] ; Create list of potential options already checked
          set options remove roost options ; Mark that the bat can't return to the same roost
          while [i < (Roosts - 2) and found? = False]
          [ ; While we haven't found a roost
            let index random length options ; Choose a random number
            let random-roost item index options ; Pick a roost
            set options remove random-roost options ; Add this to the places already checked
            if any? turtles with [random-roost = (i + 1)]
            [ ; If there are any bats present in the checked roost
              let bat-count-local count turtles with [random-roost = (i + 1)] ; Count the number of bats
              if bat-count-local < limit
              [ ; If there is an acceptable amount of bats
                let matching-bats turtles with [roost = (i + 1)] ; Find all turtles in theat roost
                set matching-bats [who] of matching-bats ; And store their id's
                let j 0 ; Create another index
                let relation-total 0 ; Initialize
                while [j < (length matching-bats) or relation-total < threshold]
                [ ; And while we have't looked at every matching bat
                  let current-bat item j matching-bats ; Isolate the bat
                  let row1 matrix:get-row relation 0 ; Get the relationship matrix
                  let current-relation item current-bat row1 ; Find the focal bat's relationship
                  set relation-total relation-total + current-relation ; Update the total relationship score for this roost
                  set j j + 1 ; And update the index
                ]
                if relation-total >= threshold
                [ ; If this is acceptable amount of relation
                  set found? True
                ]
              ]
            ]
            set i i + 1 ; Update index
          ]
          ifelse found? = False
          [ ; If we haven't found a suitable place to go
            move-to one-of patches with ([roost != [roost] of myself]) ; Move to a random roost
          ]
          [ ; If we have
            move-to one-of patches with ([roost = (i + 1)]) ; Move to the chosen roost
          ]
        ]
      ]
    ]
  ]
end

; When bats are inside, they invest in partners via grooming, this section made with the consultation and guidance of ChatGPT
to groom
  let who-list other turtles with [roost = [roost] of myself] ; Finds all other bats in the same roost
  if any? who-list
  [ ; If there are any other bats
    let my-bat 0 ; Initialize my-bat, which will be used for deciding who to groom
    if decision = 0
    [ ; If diversifyinig strategy
      let i 0 ; Create an index
      let bat-list [] ; Initialize a list to store bat already groomed
      let divisors 10 ; The number of bats groomed
      let boost round(groom_give / divisors) ; The boost from grooming each bat
      while [i < divisors]
      [ ; While there are still bats to groom
        ifelse (divisors < (count who-list))
        [ ; If there are more bats present than there are bats to groom
          ; Groom the bat that is the most familiar who hasn't already been groomed that day
          set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
          set bat-list lput my-bat bat-list ; Then mark that this bat was groomed
          let grooming who ; Then make a local variable to see who is doing the grooming
          ask my-bat
          [ ; Ask the groomed bat
            ; To have an improved relation with the grooming bat
            matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost)
            ; And get the relationship between the two, from the recipients perspective
            let relationship matrix:get relation 0 grooming
            if relationship > 100
            [ ; And if that relationship is greater than maximum (100%), make 100%
              matrix:set relation 0 grooming 100
            ]
          ]
          set i i + 1 ; Then update the index
        ]
        [ ; If there are less bats present than there are divisors
          let j 0 ; Create a second index
          ifelse (i = 0)
          [ ; If we are just starting
            while [j < (count who-list)]
            [ ; Proceed normally until you have to loop
              ; Groom the bat that is the most familiar who hasn't already been groomed that day
              set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
              set bat-list lput my-bat bat-list ; Then mark that this bat was groomed
              let grooming who ; Then make a local variable to see who is doing the grooming
              ask my-bat
              [ ; Ask the groomed bat
                ; To have an improved relation with the grooming bat
                matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost)
                ; And get the relationship between the two, from the recipients perspective
                let relationship matrix:get relation 0 grooming
                if relationship > 100
                [ ; And if that relationship is greater than maximum (100%), make 100%
                  matrix:set relation 0 grooming 100
                ]
              ]
              ; Then update both indices
              set i i + 1
              set j j + 1
            ]
          ]
          [ ; For the remainder, loop through bat-list
            ; Make a list that loops around back to the top
            let index-list n-values (divisors - j - 1) [m -> (m mod (length bat-list))]
            foreach index-list
            [ ; And for each rank in that list
              n -> set my-bat item n bat-list ; Set my-bat to be whatever bat is in the bat-list
              let grooming who ; And mark who is doing the grooming
              ask my-bat
              [ ; Ask the groomed bat
                ; To have an improved relation with the grooming bat
                matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost)
                ; And get the relationship between the two, from the recipients perspective
                let relationship matrix:get relation 0 grooming
                if relationship > 100
                [ ; And if that relationship is greater than maximum (100%), make 100%
                  matrix:set relation 0 grooming 100
                ]
              ]
              set i i + 1 ; Then update the first index
            ]
          ]
        ]
      ]
    ]
    if decision = 1
    [ ; If focusing strategy
      let i 0 ; Create an index
      let bat-list [] ; Create an empty bat list
      let boost1 0.9 * groom_give ; Let (100%) of the grooming time go to the most favored bat
      let boost2 groom_give - boost1 ; And the remainder goes to the other
      while [i < 2]
      [
        ifelse (2 < (count who-list))
        [ ; If there are more bats present than there are bats to groom
          ; Find the bat that has the highest relationship not already groomed
          set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
          set bat-list lput my-bat bat-list ; And update the list
          let grooming who ; Then mark who is grooming
          ask my-bat
          [ ; Ask the groomed bat
            ifelse i = 0
            [ ; If this is the first bat
              ; Give them the higher boost
              matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost1)
              let relationship matrix:get relation 0 grooming ; And get the relationship level
              if relationship > 100
              [ ; And if that relationship is past 100%, make 100%
                matrix:set relation 0 grooming 100
              ]
            ]
            [ ; If this is the second bat
              ; Give them the lower boost
              matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost2)
              let relationship matrix:get relation 0 grooming ; And get the relationship level
              if relationship > 100
              [ ; And if that relationship is past 100%, make 100%
                matrix:set relation 0 grooming 100
              ]
            ]
          ]
          set i i + 1 ; Update the index
        ]
        [ ; If there are less bats present than there are divisors
          let j 0 ; Make a new index
          ifelse (i = 0)
          [ ; If we are just starting
            while [j < (count who-list)]
            [ ; Proceed normally until you have to loop
              ; Find the bat that has the highest relationship not already groomed
              set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
              set bat-list lput my-bat bat-list ; And update the list
              let grooming who ; Then mark who is grooming
              ask my-bat
              [ ; Ask the groomed bat
                ifelse i = 0
                [ ; If this is the first bat
                  ; Give them the higher boost
                  matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost1)
                  let relationship matrix:get relation 0 grooming ; And get the relationship level
                  if relationship > 100
                  [ ; And if that relationship is past 100%, make 100%
                    matrix:set relation 0 grooming 100
                  ]
                ]
                [ ; If this is the second bat
                  ; Give them the lower boost
                  matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost2)
                  let relationship matrix:get relation 0 grooming ; And get the relationship level
                  if relationship > 100
                  [ ; And if that relationship is past 100%, make 100%
                    matrix:set relation 0 grooming 100
                  ]
                ]
              ]
              ; Then update both indices
              set i i + 1
              set j j + 1
            ]
          ]
          [ ; For the remainder, loop through bat-list
            let index-list n-values (2 - j - 1) [m -> (m mod (length bat-list))]
            foreach index-list
            [ ; For each item in the list
              n -> set my-bat item n bat-list ; Find the relevant
              let grooming who ; Find who is doing the grooming
              ask my-bat
              [ ; And asked the groomed bat
                ; To set the remainder of the grooming time back to the first bat
                matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost2)
                let relationship matrix:get relation 0 grooming ; And get the relationship level
                if relationship > 100
                [ ; And if that relationsjip is past 100%, make 100%
                  matrix:set relation 0 grooming 100
                ]
              ]
              set i i + 1 ; Update the index
            ]
          ]
        ]
      ]
    ]
    if decision = 2
    [
      ; If focusing strategy
      let i 0 ; Create an index
      let bat-list [] ; Create an empty bat list
      let divisors 10
      let boost 0
      while [i < divisors]
      [
        ifelse (i = (divisors - 1))
        [
          set boost 0.5 ^ (i + 1) * groom_give
        ]
        [
          set boost 0.5 ^ i * groom_give
        ]
        ifelse (divisors < (count who-list))
        [ ; If there are more bats present than there are bats to groom
          ; Find the bat that has the highest relationship not already groomed
          set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
          set bat-list lput my-bat bat-list ; And update the list
          let grooming who ; Then mark who is grooming
          ask my-bat
          [ ; Ask the groomed bat
            ; Give them the higher boost
            matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost)
            let relationship matrix:get relation 0 grooming ; And get the relationship level
            if relationship > 100
            [ ; And if that relationship is past 100%, make 100%
              matrix:set relation 0 grooming 100
            ]
          ]
          set i i + 1 ; Update the index
        ]
        [ ; If there are less bats present than there are divisors
          let j 0 ; Make a new index
          ifelse (i = 0)
          [ ; If we are just starting
            while [j < (count who-list)]
            [ ; Proceed normally until you have to loop
              ifelse (i = (divisors - 1))
              [
                set boost 0.5 ^ (i + 1) * groom_give
              ]
              [
                set boost 0.5 ^ i * groom_give
              ]
              ; Find the bat that has the highest relationship not already groomed
              set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
              set bat-list lput my-bat bat-list ; And update the list
              let grooming who ; Then mark who is grooming
              ask my-bat
              [ ; Ask the groomed bat
                ; Give them the higher boost
                matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost)
                let relationship matrix:get relation 0 grooming ; And get the relationship level
                if relationship > 100
                [ ; And if that relationship is past 100%, make 100%
                  matrix:set relation 0 grooming 100
                ]
              ]
              ; Then update both indices
              set i i + 1
              set j j + 1
            ]
          ]
          [ ; For the remainder, loop through bat-list
            let index-list n-values (divisors - j - 1) [m -> (m mod (length bat-list))]
            foreach index-list
            [ ; For each item in the list
              n -> set my-bat item n bat-list ; Find the relevant
              ifelse (i = (divisors - 1))
              [
                set boost 0.5 ^ (i + 1) * groom_give
              ]
              [
                set boost 0.5 ^ i * groom_give
              ]
              let grooming who ; Find who is doing the grooming
              ask my-bat
              [ ; And asked the groomed bat
                ; To set the remainder of the grooming time back to the first bat
                matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost)
                let relationship matrix:get relation 0 grooming ; And get the relationship level
                if relationship > 100
                [ ; And if that relationsjip is past 100%, make 100%
                  matrix:set relation 0 grooming 100
                ]
              ]
              set i i + 1 ; Update the index
            ]
          ]
        ]
      ]
    ]
    if decision = 3
    [
      ; If focusing strategy
      let i 0 ; Create an index
      let bat-list [] ; Create an empty bat list
      let boost1 0.5 * groom_give ; Let (100%) of the grooming time go to the most favored bat
      let boost2 groom_give - boost1 ; And the remainder goes to the other
      while [i < 2]
      [
        ifelse (2 < (count who-list))
        [ ; If there are more bats present than there are bats to groom
          ; Find the bat that has the highest relationship not already groomed
          set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
          set bat-list lput my-bat bat-list ; And update the list
          let grooming who ; Then mark who is grooming
          ask my-bat
          [ ; Ask the groomed bat
            ifelse i = 0
            [ ; If this is the first bat
              ; Give them the higher boost
              matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost1)
              let relationship matrix:get relation 0 grooming ; And get the relationship level
              if relationship > 100
              [ ; And if that relationship is past 100%, make 100%
                matrix:set relation 0 grooming 100
              ]
            ]
            [ ; If this is the second bat
              ; Give them the lower boost
              matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost2)
              let relationship matrix:get relation 0 grooming ; And get the relationship level
              if relationship > 100
              [ ; And if that relationship is past 100%, make 100%
                matrix:set relation 0 grooming 100
              ]
            ]
          ]
          set i i + 1 ; Update the index
        ]
        [ ; If there are less bats present than there are divisors
          let j 0 ; Make a new index
          ifelse (i = 0)
          [ ; If we are just starting
            while [j < (count who-list)]
            [ ; Proceed normally until you have to loop
              ; Find the bat that has the highest relationship not already groomed
              set my-bat max-one-of who-list with [not member? self bat-list] [matrix:get relation 0 who]
              set bat-list lput my-bat bat-list ; And update the list
              let grooming who ; Then mark who is grooming
              ask my-bat
              [ ; Ask the groomed bat
                ifelse i = 0
                [ ; If this is the first bat
                  ; Give them the higher boost
                  matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost1)
                  let relationship matrix:get relation 0 grooming ; And get the relationship level
                  if relationship > 100
                  [ ; And if that relationship is past 100%, make 100%
                    matrix:set relation 0 grooming 100
                  ]
                ]
                [ ; If this is the second bat
                  ; Give them the lower boost
                  matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost2)
                  let relationship matrix:get relation 0 grooming ; And get the relationship level
                  if relationship > 100
                  [ ; And if that relationship is past 100%, make 100%
                    matrix:set relation 0 grooming 100
                  ]
                ]
              ]
              ; Then update both indices
              set i i + 1
              set j j + 1
            ]
          ]
          [ ; For the remainder, loop through bat-list
            let index-list n-values (2 - j - 1) [m -> (m mod (length bat-list))]
            foreach index-list
            [ ; For each item in the list
              n -> set my-bat item n bat-list ; Find the relevant
              let grooming who ; Find who is doing the grooming
              ask my-bat
              [ ; And asked the groomed bat
                ; To set the remainder of the grooming time back to the first bat
                matrix:set relation 0 grooming ((matrix:get relation 0 grooming) + boost2)
                let relationship matrix:get relation 0 grooming ; And get the relationship level
                if relationship > 100
                [ ; And if that relationsjip is past 100%, make 100%
                  matrix:set relation 0 grooming 100
                ]
              ]
              set i i + 1 ; Update the index
            ]
          ]
        ]
      ]
    ]
  ]
end

; Bats then ask for donation if they didn't find food previously, this section made with the consultation and guidance of ChatGPT
to share
  if fed? = FALSE
  [ ; If the bat didn't find food
    ; Find all bats with the same roost
    let turtles-with-same-roost other turtles with [roost = [roost] of myself]
    if any? turtles-with-same-roost
    [ ; And if there are any
      ; Get a list of bat IDs
      let who-list map [t -> [who] of t] (list turtles-with-same-roost)
      let flattened-who-list reduce sentence who-list ; Flatten the list
      let relationship-vector n-values (length flattened-who-list) [0]
      let i 0 ; Initialize a local variable
      while [i < length flattened-who-list]
      [
        let bat-number item i flattened-who-list
        let bat-relation matrix:get relation 0 bat-number
        set relationship-vector replace-item i relationship-vector bat-relation
        set i i + 1
      ]
      let sorted-who-list (sort-by [[t1 t2] -> compare-relations t1 t2] flattened-who-list) ; Sort by relation
      let my-bat 0 ; Initialize a local variable for the chosen bat
      set i 0 ; And make an index
      while [(i < (length sorted-who-list)) and (fed? = False)]
      [ ; While we haven't looked at every bat
        set my-bat item ((length sorted-who-list) - 1 - i) sorted-who-list ; Mark the new bat
        let relationship 0 ; Initialize the relationship local variabe
        let other-bat who ; Mark the bat that needs food
        ask turtles with [who = my-bat]
        [ ; Ask the bat being asked for food
          set relationship matrix:get relation 0 other-bat ; To state their relationship
        ]
        let b random-float 1 ; Generate a random number
        let p_donation 100 / (1 + exp(-0.1 * (relationship - 50))) ; And calculate the probability of giving a donation
        let donating my-bat ; And, to make things easier, mark them as donating
        let R 0 ; Initialize R, or reserves
        let eaten False ; Initialize eaten as False
        ask turtles with [who = my-bat]
        [ ; Ash the potential donating bat
          set R donate_give ; To set the reserves to how much they can donate
          set eaten fed? ; And mark whether they have eaten or not
        ]
        ifelse b < p_donation and R > 0 and fed? = False
        [ ; If marked to donate, and there are reserves to share
          set donate_need donate_need - 1 ; set how much they need donated
          let done_feeding False ; Initialize done_feeding, which determines whether they are fed
          ; Update the relaionship to increase because of the accepted donation
          matrix:set relation 0 donating ((matrix:get relation 0 donating) + 5)
          let relations matrix:get relation 0 donating ; And pull out the relationship
          if relations > 100
          [ ; If that relationship is greater than 100%, set to 100%
            matrix:set relation 0 donating 100
          ]
          ask turtles with [who = my-bat]
          [ ; ask the donating bat
            set donate_give donate_give - 1 ; To decrease the amount they can donate
            set R donate_give ; Then update the local reserves variable
          ]
          if donate_need = 0
          [ ; If the bat is full
            set fed? True ; Mark that they have been fed
            set days-since-eat 0 ; And set that they have eaten today
          ]
          while [done_feeding = False and fed? = False] ;or R > 0]
          [ ; While the bat is not done feeding and the bat is not fed
            set b random-float 1 ; Set a new random number
            ifelse b < p_donation and R > 0
            [ ; If the bat donates blood and has food to give
              set donate_need donate_need - 1 ; Show that the bat gave food
              ; Update their relationship
              matrix:set relation 0 donating ((matrix:get relation 0 donating) + 5)
              set relations matrix:get relation 0 donating
              if relations > 100
              [ ; And dif that relationship is greater than 100%, set to 100%
                matrix:set relation 0 donating 100
              ]
              ask turtles with [who = my-bat]
              [ ; Then ask the bats to update how much food they can give
                set donate_give donate_give - 1
                set R donate_give
              ]
              if donate_need = 0
              [ ; If the bat no longer needs food
                set fed? True ; Mark that it has fed
                set days-since-eat 0 ; And state its time since last fed as 0
              ]
            ]
            [ ; If the bat can't give food
              set done_feeding True ; Mark that the donating bat is done feeding the asking bat
            ]
          ]
          if fed? = False
          [ ; If the bat is stil not fed
            set i i + 1 ; Update the index
          ]
        ]
        [ ; If refused to donate
          set i i + 1 ; Update the index
          ; Deteriorate the relationship
          matrix:set relation 0 donating ((matrix:get relation 0 donating) - 5)
          let relations matrix:get relation 0 donating
          if relations < 0
          [ ; And make sure that relationship is not less than 0%
            matrix:set relation 0 donating 0
          ]
        ]
      ]
    ]
  ]
end

; If the bat hasn't eaten in three days, it will starve
to starve
  if days-since-eat >= 3
  [ ; If the bat hasn't eaten in three days
    let dead-who who ; Find the bat ID
    ask turtles with [who != dead-who]
    [ ; Set all other bats relation with this bat to zero
      matrix:set relation 0 dead-who 0
    ]
    die ; And kill the bat
  ]
  if age > (18 * 365)
  [ ; Also, if the bat is greater than 18 years old
    let dead-who who ; Find the bat ID
    ask turtles with [who != dead-who]
    [ ; Set all other bats relation with this bat to zero
      matrix:set relation 0 dead-who 0
    ]
    die ; And kill the bat
  ]
end

; Survivng bats may reproduce asexually
to birth
  if age > (365 * 2)
  [ ; If the bat is older than 2 years old
    if (remainder age (7 * 30)) = 0
    [ ; And seven months have passed since last birt (or 28 months old)
      let mom-who who ; Set the mother
      hatch 1 [ ; Make one new bat
        set age 0 ; Set age to 0
        set last-switch 0 ; Set days since last switch to zero
        set days-since-eat 0 ; Set days since last eaten to zero
        set mother mom-who ; Set mother
        set decision decision ; Make sure the decision is the same as the mothers
        set fed? TRUE ; Mark that it has been fed
        matrix:set relation 0 mom-who 100 ; Set the relationship of the mom and child to 100
        let child-who who
        ask turtles with [who = mom-who]
        [ ; Set the relationship of the mom and child to 100
          matrix:set relation 0 child-who 100
          set children child-who ; Set the child REPLACES CHILDREN
        ]
      ]
    ]
  ]
end

; Used to run the simulation
to go
  set Bats count turtles
  ;ask turtles
  ;[ ; All relationships decrease by 'decay'
  ;  set relation matrix:map [n -> max list 0 (n - decay)] relation
  ;]
  ask turtles
  [ ; Turtles find food
    set groom_give 10 ; Maximum percentage increase from grooming
    feed
    matrix:set relation 0 who 0 ; Doing this to make sure the bat never 'prefers itself'
  ]
  if roost-switch? = True
  [ ; If we have roost switching
    ask patches
    [
      let a roost
      set bat-count count turtles with [roost = a]
    ]
    ask turtles
    [ ; Ask turtles to move to same or new roost
      move
      matrix:set relation 0 who 0
    ]
  ]
  ask patches
  [
    let a roost
    set bat-count count turtles with [roost = a]
  ]
  ask turtles
  [ ; Ask children to move dependent on parent position
    move-children
    matrix:set relation 0 who 0
  ]
  ask patches
  [
    let a roost
    set bat-count count turtles with [roost = a]
  ]
  ask turtles with [age < 7 * 30]
  [ ; Ask bats to groom each other
    groom
    matrix:set relation 0 who 0
  ]
  ask turtles with [age >= 7 * 30 and age < 365 * 2]
  [ ; Ask bats to groom each other
    groom
    matrix:set relation 0 who 0
  ]
  ask turtles with [age >= 365 * 2]
  [ ; Ask bats to groom each other
    groom
    matrix:set relation 0 who 0
  ]
  ask turtles
  [ ; Ask bats to share food, or ask for donations
    share
    matrix:set relation 0 who 0
  ]
  ask turtles
  [ ; Kill bats who haven't eaten
    starve
    matrix:set relation 0 who 0
  ]
  ask turtles
  [ ; Asexual reproduction
    birth
    matrix:set relation 0 who 0
    set age age + 1 ; Age the bats after all processes finished
  ]
  if ((red_pop_extinct = False) and (count turtles with [color = red] = 0)) [
    show "red pop extinct at:"
    set red_pop_extinct True
    show ticks
  ]
  if ((orange_pop_extinct = False) and (count turtles with [color = orange] = 0)) [
    show "orange pop extinct at:"
    set orange_pop_extinct True
    show ticks
  ]
  if ((yellow_pop_extinct = False) and (count turtles with [color = yellow] = 0)) [
    show "yellow pop extinct at:"
    set yellow_pop_extinct True
    show ticks
  ]
  if ((green_pop_extinct = False) and (count turtles with [color = green] = 0)) [
    show "green pop extinct at:"
    set green_pop_extinct True
    show ticks
  ]
  tick ; Update ticks
  if count turtles = 0
  [ ; Stop program if everyone is dead
    stop
  ]
  if ticks = Days
  [ ; If we have gone through Days ticks, stop the program
    show "red:"
    show count turtles with [color = red]
    show "orange"
    show count turtles with [color = orange]
    show "yellow"
    show count turtles with [color = yellow]
    show "green"
    show count turtles with [color = green]
    stop
  ]
end

to-report compare-relations [t1 t2]
  let relation1 matrix:get relation 0 t1
  let relation2 matrix:get relation 0 t2
  if relation1 > relation2 [report true]
  report false
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
618
319
-1
-1
50.0
1
10
1
1
1
0
1
1
1
-4
3
-2
3
0
0
1
ticks
30.0

BUTTON
98
55
161
88
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
59
125
122
158
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
6
182
206
332
plot
days
counts
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"
"pen-1" 1.0 0 -15040220 true "" "plot count turtles with [decision = 0]"
"pen-2" 1.0 0 -2674135 true "" "plot count turtles with [decision = 1]"
"pen-3" 1.0 0 -7171555 true "" "plot count turtles with [decision = 2]"
"pen-4" 1.0 0 -955883 true "" "plot count turtles with [decision = 3]"

SWITCH
41
90
170
123
roost-switch?
roost-switch?
0
1
-1000

SWITCH
45
18
164
51
social-pref?
social-pref?
0
1
-1000

SLIDER
222
317
394
350
limit
limit
10
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
433
322
605
355
foraging
foraging
0
1
0.85
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="6" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [color = green]</metric>
    <metric>count turtles with [color = yellow]</metric>
    <metric>count turtles with [color = orange]</metric>
    <metric>count turtles with [color = red]</metric>
    <enumeratedValueSet variable="roost-switch?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-pref?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="limit">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="foraging">
      <value value="85"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
