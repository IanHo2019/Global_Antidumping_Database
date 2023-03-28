* This do file withdraws data from Global Antidumping Database (version 6.0). My goal is to construct a product-case level dataset.
* Author: Ian He
* Date: Mar 26, 2023

clear all

global localdir "D:\research\GAD_Cleaning"

global rawdir	"$localdir\GAD"
global dtadir	"$localdir\GAD_dta"



*************************************************************************
**# Withdraw data from Master and Products sheets
* AD Cases in OTH (other) excel file are not included.
local ctylist = "ARG AUS BRA CAN CHL CHN COL CRI ECU EUN IDN IND ISR JAM JPN KOR MEX MYS NZL PAK PRY RUS THA TTO TUR TWN UKR URY USA VEN ZAF"

foreach var in `ctylist'{
	* Master
	import excel "$rawdir\GAD-`var'.xls", sheet("AD-`var'-Master") firstrow case(lower) allstring clear
	drop if v_number == ""
	save "$dtadir\AD-`var'-Master.dta", replace
	
	* Products
	import excel "$rawdir\GAD-`var'.xls", sheet("AD-`var'-Products") firstrow case(lower) allstring clear
	keep case_id hs_code hs_digits
	save "$dtadir\AD-`var'-Products.dta", replace
}

* Peru
import excel "$rawdir\GAD-PER.xls", sheet("AD-PER-Master") cellrange(A1:AI128) firstrow case(lower) allstring clear
drop if v_number == ""
save "$dtadir\AD-PER-Master.dta", replace

import excel "$rawdir\GAD-PER.xls", sheet("AD-PER-Products") cellrange(A1:C391) firstrow case(lower) allstring clear
keep case_id hs_code hs_digits
save "$dtadir\AD-PER-Products.dta", replace

* Philippines
import excel "$rawdir\GAD-PHL.xls", sheet("AD-PHL-Master") cellrange(A1:AA24) firstrow case(lower) allstring clear
drop if v_number == ""
save "$dtadir\AD-PHL-Master.dta", replace

import excel "$rawdir\GAD-PHL.xls", sheet("AD-PHL-Products") cellrange(A1:C53) firstrow case(lower) allstring clear
keep case_id hs_code hs_digits
save "$dtadir\AD-PHL-Products.dta", replace



*************************************************************************
**# Merge Products & Master Sheets
local full_list = "ARG AUS BRA CAN CHL CHN COL CRI ECU EUN IDN IND ISR JAM JPN KOR MEX MYS NZL PAK PER PHL PRY RUS THA TTO TUR TWN UKR URY USA VEN ZAF"

foreach var in `full_list'{
	use "$dtadir\AD-`var'-Products.dta", clear
	merge m:1 case_id using "$dtadir\AD-`var'-Master.dta"
	drop _merge
	save "$dtadir\AD-`var'.dta", replace
}


* Append data sets
use "$dtadir\AD-ARG.dta", clear

local full_list_withoutARG = "AUS BRA CAN CHL CHN COL CRI ECU EUN IDN IND ISR JAM JPN KOR MEX MYS NZL PAK PER PHL PRY RUS THA TTO TUR TWN UKR URY USA VEN ZAF"

foreach var in `full_list_withoutARG'{
	append using "$dtadir\AD-`var'.dta"
}


* Set a consistent format for all dates
local date_list = "init_date p_dump_date p_inj_date p_ad_date f_dump_date f_inj_date f_ad_date revoke_date"

foreach var in `date_list'{
	gen `var'_num = date(`var', "DMY")
	format `var'_num %td
	replace `var'_num = date(`var', "MDY") if `var'_num == .
	format `var'_num %td
	drop `var'
	rename `var'_num `var'
}


* Generate ISO code (alpha-3) for each country
gen ad_cty_code = substr(case_id, 1, 3)
replace ad_cty_code = upper(ad_cty_code)

* Add descriptive labels to variables of interest
label var case_id "Case identifier"

label var v_number "Quarter and year of last data update"

label var ad_cty_name "Country initiating AD"

label var ad_cty_code "Country (code) initiating AD"

label var inv_cty_code "Country (code) subject to AD"

label var product "Product under investigation"

label var init_date "Date of initiation"

label var p_dump_date "Date of preliminary dumping decision"

label var p_inj_date "Date of preliminary injury decision"

label var p_dump_dec "Preliminary dumping decision"

label var p_inj_dec "Preliminary injury decision"

label var p_ad_date "Date of imposition of preliminary AD measure"

label var f_dump_date "Date of final dumping decision"

label var f_inj_date "Date of final injury decision"

label var f_dump_dec "Final dumping decision"

label var f_inj_dec "Final injury decision"

label var f_ad_date "Date of imposition of final AD measure"

label var revoke_date "Date of revocation of AD"

label var revoke_year "Year of revocation of AD"

label var p_ad_duty "Preliminary AD duty imposed"

label var f_ad_duty "Final AD duty imposed"


* Drop if case_id is missing
drop if case_id == ""
sort case_id


save "$dtadir\GAD_full_product_case.dta", replace
