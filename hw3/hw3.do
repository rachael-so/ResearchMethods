import delimited "sports-and-education.csv", clear
// list
describe

. global balanceopts "prehead(\begin{tabular}{l*{6}{c}}) postfoot(\end{tabular}) noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01)"

. estpost ttest academicquality athleticquality nearbigmarket, by(ranked2017) unequal welch

esttab . using test.tex, cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") wide label collabels("Control" "Treatment" "Difference") noobs $balanceopts mlabels(none) eqlabels(none) replace mgroups(none)

/******* build a propensity score model *******/
logit ranked2017 academicquality athleticquality nearbigmarket
. predict propensity_score, pr
summarize propensity_score

twoway histogram propensity_score, start(.1) width(.05) bc(red%30) freq || histogram propensity_score if ranked2017==0, start(.1) width(.05) bc(blue%30) freq legend(order(1 "Treatment (Ranked)" 2 "Control (Unranked)"))

. sort propensity_score
. gen block = floor(_n/4)

label variable alumnidona~2018 "Donations"
label variable ranked2017 "Ranked in 2017"
label variable academicquality "Academic Quality"
label variable athleticquality "Athletic Quality"
label variable nearbigmarket "Near Big Market"
label variable block "Block"

regress alumnidona~2018 ranked2017 academicquality athleticquality nearbigmarket i.block

// esttab using treatment_effect.txt, replace label b(%9.3f) p(%9.3f)
esttab using treatment_effect.txt, replace label b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)
