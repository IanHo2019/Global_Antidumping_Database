# Global Antidumping Database ([Bown, 2016](https://www.chadpbown.com/global-antidumping-database/))
This repository shows how to clean the **Global Antidumping Database (GAD)** and do some summary statistics. Comments on better coding or errors are welcomed. **Contact:** [ianhe2019@ou.edu](mailto:ianhe2019@ou.edu?subject=[GitHub]%20GAD).

The GAD was published by Chad P. Bown and collects detailed information on the national use of antidumping (AD) duties in 40 countries and European Union. Fortunately, the database is freely available; unfortunately, Bown claimed that he no longer updates the data. The version I cleaned is version 6.0, updated in June 2016 and containing data through 2015Q4.


## Key Information about the Database
* The raw data for each AD user country is saved in a Microsoft Excel 97-2003 Worksheet file, within which are typically four spreadsheets:
  * A "**Master**" sheet collecting case-level data on important dates and decision outcomes. For example, in the US, an AD case usually has 7 important dates, including initiation date, ITC preliminary determination date, DOC preliminary determination date, ITC final determination date, DOC final determination date, AD imposition date, and revoke date. An illustration of time frame for US AD investigations can be found [here](https://www.trade.gov/statutory-time-frame-adcvd-investigations).
  * A "**Products**" sheet collecting case-product data on the [Harmonized System (HS)](https://en.wikipedia.org/wiki/Harmonized_System) product codes listed in the AD investigation petition. The digits of HS code vary across cases and user countries; for example, China's AD cases are usually at 6-digit HS level and the US AD cases are usually at 10-digit HS level.
  * A "**Domestic Firms**" sheet collecting a set of data on domestic firms that submitted petitions to request the AD investigations, and a "**Foreign Firms**" sheet collecting a set of data on foreign firms subject to the AD investigation. Here I will skip these two sheets because my focus is on the country-product-level statistics of the AD investigations.


## Cleaning the Database
I used Stata to clean up and construct a product-case level dataset. The procedure consists of two steps:
  1. Withdraw data from the raw database (in xls format).
  1. Clean up data to include only information on AD cases against China. This is just an example; you can follow the coding to easily contruct a dataset with cases against other countries.

I don't clean or reconstruct the dataset when I am withdrawing data; this is the most efficient way to deal with a big dataset, in my opinion.


### Note on Withdrawal
* I use the `foreach` loop to withdraw data from Excel sheets; however, data on Peru (**PER**) and Philippines (**PHL**) cannot be withdrawn succefully if they are included in the loop. That's why I withdraw their data independently.

