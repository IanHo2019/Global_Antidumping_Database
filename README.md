# Global Antidumping Database ([Bown, 2016](https://www.chadpbown.com/global-antidumping-database/))
This repository shows how to clean the **Global Antidumping Database (GAD)** and do some summary statistics. Comments on better coding or errors are welcomed. **Contact:** [ianhe2019@ou.edu](mailto:ianhe2019@ou.edu?subject=[GitHub]%20GAD).

The GAD was published by Chad P. Bown and collects detailed information on the national use of antidumping (AD) duties over the world. Fortunately, the database is freely available; unfortunately, Bown claimed that he no longer updates the data. The version I cleaned is version 6.0, updated in June 2016 and containing data through 2015Q4.

## Cleaning the Database
I used Stata to clean up and construct a product-case level dataset. The procedure consists of two steps:
  1. Withdraw data from the raw database (in xls format).
  1. Clean up data to include only information on AD cases against China. This is just an example; you can follow the coding to easily contruct a dataset with cases against other countries.
