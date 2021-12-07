source(
  "./stud-solution.R",
  chdir = TRUE
)

library(testthat)
local_edition(3)
math_sol <- 2 + 4


test_that("correct math object", 
          {
            expect_equal(
              math, # students' object
              math_sol   # solution object
            )
          }
)
