* This do file cleans data from Global Antidumping Database (version 6.0). My goal is cleaning up to get a product-case level dataset with only cases against China.
* Author: Ian He
* Date: Mar 26, 2023
*************************************************************************

clear all

global localdir "D:\research\GAD_Cleaning"

global dtadir	"$localdir\GAD_dta"
global clndir	"$localdir\GAD_cleaned"


* Keep only cases against China
use "$dtadir\GAD_full_product_case.dta", clear

keep if inv_cty_code == "CHN"


*************************************************************************
**# Weak cleaning up

* Only keep useful information
keep case_id hs_code ad_cty_name ad_cty_code ///
	init_date p_dump_date p_ad_date p_inj_date ///
	f_dump_date f_inj_date f_ad_date revoke_date ///
	p_dump_dec p_inj_dec f_dump_dec f_inj_dec ///
	f_ad_duty f_marginmax f_avg_duty notes


* Adjust country variable
ren ad_cty_name area_name
ren ad_cty_code area_code

replace area_name= "Israel" if area_name=="Israel  "


* Drop cases with no product information
drop if hs_code=="MI"
drop if hs_code=="."


* Construct a variable storing antidumping duty
gen ad_duty = f_ad_duty
replace ad_duty = f_marginmax if area_code == "AUS"
replace ad_duty = f_avg_duty if area_code == "CAN" | area_code == "TWN"
drop f_ad_duty f_marginmax f_avg_duty


*************************************************************************
**# Strong cleaning up

* Select periods (e.g., 2000-2009)
local year_var = "init p_dump p_inj p_ad f_dump f_inj f_ad revoke"

foreach v in `year_var'{
	* convert date to year-month
	gen `v'_ym = mofd(`v'_date)
	format `v'_ym %tm
	
	* convert date to year
	gen `v'_year = year(`v'_date)
	drop `v'_date
}

keep if inrange(init_year, 2000, 2009)


* Product-level 
gen hs08 = substr(hs_code, 1, 8)
gen hs06 = substr(hs08, 1, 6)	// Most international trade research is at 6-digit HS level


* Drop repetitive cases
bysort area_name hs06 init_year: gen dup = cond(_N==1, 0, _n)
drop if dup > 1


* make dataset more readable
order area_code area_name hs06 hs08, first
order ad_duty, before(notes)
drop case_id hs_code dup
sort init_year hs08 area_code
format f_inj_dec %9s
format ad_duty %20s


save "$clndir\GAD_CHN_product_case.dta", replace