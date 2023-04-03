# Global Antidumping Database ([Bown, 2016](https://www.chadpbown.com/global-antidumping-database/))
This repository shows how to clean the **Global Antidumping Database (GAD)** and do some summary statistics. Comments on better coding or errors are welcomed. **Contact:** [ianhe2019@ou.edu](mailto:ianhe2019@ou.edu?subject=[GitHub]%20GAD).

The GAD was published by Chad P. Bown and collects detailed information on the national use of antidumping (AD) investigations in 40 countries and European Union. Fortunately, the database is freely available; unfortunately, Bown claimed that he no longer updates the data. The version I cleaned is version 6.0, updated in June 2016 and containing data through 2015Q4.


## Introduction to the AD Investigation
According to the WTO, before successfully imposing an AD duty, the importing country must affirm the existence of two phenomena:
  1. the export firm is actually **dumping** its products;
  2. the dumpling behavior is causing **injury** to the market in the importing country.

The process of investigating the dumping and injury is called **antidumping investigation**, which is the responsibility of one or two government agencies. A **single-track** AD investigative process refers to a system in which there is only one government agency carrying out the dumping and injury investigations at the same time, and a **dual-track** process is a system in which two independent government agencies handle the AD dumping and injury investigations. Most countries follows a single track procedure; the typical countries that follows a dual-track procedure are China and the US.


## Introduction to the Database
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
* I save 34 raw data files in a folder named "GAD". To run my coding ([here](./Step1_Withdraw_Data.do)), you need change the file path in the do file.
* I use the `foreach` loop to withdraw data from Excel sheets; however, data on Peru (**PER**) and Philippines (**PHL**) cannot be withdrawn succefully if they are included in the loop [I get an error message: r(198)]. That's why I withdraw their data independently.
* I use `merge m:1` to merge data from Products and Master sheets. "Products" is in memory (called *master file* in Stata language) and "Master" is the *using file*. Note that an AD case may investigate multiple products from the same foreign country.
* The key date variables are stored in "dd/mm/yyyy" or "mm/dd/yyyy" format in the raw database. They include
  * Date of initiation.
  * Dates of preliminary dumping and injury decisions. 
  * Dates of final dumping and injury decisions.
  * Dates of imposition of final AD measure.
  * Date of revocation of AD measure.

### Note on Construction
* My first step in constructing a dataset is always drop those useless variables; especially in a big dataset, this action could reduce Stata running time a lot.
