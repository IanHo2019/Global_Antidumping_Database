* This do file does summary statistics for the Global Antidumping Database, but only including cases against China whose initiation dates are between 2000 and 2009.
* Author: Ian He
* Date: Apr 11, 2023
***************************************************************************

clear

global localdir "D:\research\GAD_Cleaning"

global gaddir	"$localdir\GAD_cleaned"
global tabdir	"$localdir\Tables"
global figdir	"$localdir\Figures"



***************************************************************************
**# Number of products investigated, by time
use "$gaddir\GAD_CHN_product_case.dta", clear

* Construct a marker for counting
gen cty_hs06 = area_code + hs06
encode cty_hs06, gen(cty_hs06_num)

collapse (count) inv_num=cty_hs06_num, by(init_ym)


* Plot: Number of products by initial dates
twoway bar inv_num init_ym, ///
	title("(A) Number of Products Investigated", color(black) size(medlarge) position(11)) ///
	xtitle("") ytitle("") ///
	xlab(480(24)600, labsize(small)) ylab(, labsize(small)) ///
	fcolor(navy) lcolor(navy) barwidth(1) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph save "$figdir\Number of Investigations.gph", replace



***************************************************************************
**# Number of products receiving duties, by time
use "$gaddir\GAD_CHN_product_case.dta", clear

* Keep only products receiving duties
gen pass_num = 1 if f_dump_dec == "A" & f_inj_dec == "A"
replace pass_num = 1 if f_dump_dec == "P" & f_inj_dec == "A"
replace pass_num = 1 if f_dump_dec == "A" & f_inj_dec == "P"
replace pass_num = 1 if f_dump_dec == "P" & f_inj_dec == "P"
drop if pass_num == .

gen cty_hs06 = area_code + hs06
encode cty_hs06, gen(cty_hs06_num)

collapse (count) duty_num=cty_hs06_num, by(f_ad_ym)
drop if f_ad_ym==.

format %10.0g f_ad_ym
format %tm f_ad_ym

* Plot: Number of products by final imposition dates
twoway bar duty_num f_ad_ym, ///
	title("(B) Number of Products Receiving Duties", color(black) size(medlarge) position(11)) ///
	xtitle("") ytitle("") ///
	xlab(492(24)636, labsize(small)) ylab(, labsize(small)) ///
	fcolor(navy) lcolor(navy) barwidth(1) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph save "$figdir\Number of Impositions.gph", replace


* Combine graphs
graph combine "$figdir\Number of Investigations.gph" "$figdir\Number of Impositions.gph", ///
	col(1) iscale(.5) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph export "$figdir\Number_of_Products.pdf", replace



***************************************************************************
**# Number of products, by area
use "$gaddir\GAD_CHN_product_case.dta", clear

* Keep only products receiving duties
gen pass_num = 1 if f_dump_dec == "A" & f_inj_dec == "A"
replace pass_num = 1 if f_dump_dec == "P" & f_inj_dec == "A"
replace pass_num = 1 if f_dump_dec == "A" & f_inj_dec == "P"
replace pass_num = 1 if f_dump_dec == "P" & f_inj_dec == "P"


* Number of products
collapse (count) number=init_year (sum) pass=pass_num, by(area_code)

set obs 25
replace area_code = "Sum" in 25


* Total number of products
egen case_total = total(number)
replace number = case_total in 25


* Proportion (rate) of products receiving duties, by country/region
egen pass_total = total(pass)
replace pass = pass_total in 25

gen pass_rate = pass/number*100
format %9.2f pass_rate

* Export a table
drop case_total pass_total 
order area_code number pass pass_rate

* Install "dataout" package
dataout, save("$tabdir\Table_GAD") tex replace



***************************************************************************
**# Average duration of investigation and duty imposition
use "$gaddir\GAD_CHN_product_case.dta", clear

* find the later date for preliminary and final decisions
egen p_decision_ym = rowmax(p_dump_ym p_inj_ym)
egen f_decision_ym = rowmax(f_dump_ym f_inj_ym)


* calculate month difference
gen duration_p_inv = p_decision_ym - init_ym	// from initiation to preliminary decision
gen duration_f_inv = f_decision_ym - init_ym	// from initiation to final decision
gen duration_duty = revoke_ym - f_ad_ym			// from final decision to revoke
replace duration_p_inv = . if duration_p_inv < 0
replace duration_f_inv = . if duration_f_inv < 0
replace duration_duty = . if duration_duty < 0

summarize duration_p_inv duration_f_inv duration_duty

collapse (mean) p_inv=duration_p_inv f_inv=duration_f_inv duty=duration_duty, by(area_code)

format %9.1f p_inv f_inv duty


* Single or dual track
* 1: AUS BRA CHL COL (Costa Rica) ECU EUN IND ISR JAM MYS MEX NZL PAK PRY PER PHL ZAF KOR THA TTO URY VEN
* 2: ARG CAN CHN TWN TUR USA
gen track = "one"
local dual_list = "ARG CAN CHN TWN TUR USA"
foreach cty in `dual_list'{
	replace track = "two" if area_code == "`cty'"
}


dataout, save("$tabdir\Table_duration") dec(1) tex replace



***************************************************************************
**# What industries were investigated and what industries received AD duty?
use "$gaddir\GAD_CHN_product_case.dta", clear

gen pass_num = 1 if f_dump_dec == "A" & f_inj_dec == "A"
replace pass_num = 1 if f_dump_dec == "P" & f_inj_dec == "A"
replace pass_num = 1 if f_dump_dec == "A" & f_inj_dec == "P"
replace pass_num = 1 if f_dump_dec == "P" & f_inj_dec == "P"
replace pass_num = 0 if pass_num == .

gen hs02 = substr(hs06, 1, 2)
destring hs02, gen(hs02_num)

* See the exact 2-digit HS code
tab hs02
tab hs02 if pass_num==1


* Histogram plots
histogram hs02_num, frequency ///
	title("(A) Receiving AD Investigation", color(black) size(medlarge) position(11)) ///
	xtitle("HS02") ytitle("Number") ///
	xlabel(10(10)90, labsize(small)) ///
	ylabel(, nogrid angle(0) labsize(small)) ///
	yline(50(50)200, lc(gs13) lp(shortdash)) ///
	fcolor(sand) lcolor(sand) width(1) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph save "$figdir\Industries_Receiving_Investigation.gph", replace


histogram hs02_num if pass_num == 1, frequency ///
	title("(B) Receiving AD Duty", color(black) size(medlarge) position(11)) ///
	xtitle("HS02") ytitle("Number") ///
	xlabel(10(10)90, labsize(small)) ///
	ylabel(, nogrid angle(0) labsize(small)) ///
	yline(20(20)100, lc(gs13) lp(shortdash)) ///
	fcolor(sand) lcolor(sand) width(1) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph save "$figdir\Products_Receiving_Duty.gph", replace


graph combine "$figdir\Industries_Receiving_Investigation.gph" "$figdir\Products_Receiving_Duty.gph", ///
	col(1) iscale(.5) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph export "$figdir\Industries.pdf", replace