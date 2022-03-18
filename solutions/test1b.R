source(
  "./solution.R",
  chdir = TRUE
)

library(testthat)
local_edition(3)
math_sol <- 2 + 4
math2_sol <- math_sol * 6

test_that("correct math2 object?", 
          {
            expect_equal(
              math2, # students' object
              math2_sol   # solution object
            )
          }
)
