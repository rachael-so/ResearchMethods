import delimited "crime-iv.csv", clear
describe
// list

// perform a balance test
. global balanceopts "prehead(\begin{tabular}{l*{6}{c}}) postfoot(\end{tabular}) noisily noeqlines nonumbers varlabels(_cons Constant, end("" ) nolast)  starlevels(* 0.1 ** 0.05 *** 0.01)"

. estpost ttest severityofcrime, by(republicanjudge) unequal welch

esttab . using test.txt, cell("mu_1(f(3)) mu_2(f(3)) b(f(3) star)") wide label collabels("Control" "Treatment" "Difference") noobs $balanceopts mlabels(none) eqlabels(none) replace mgroups(none)

// first stage regression
reg monthsinjail republicanjudge severityofcrime
estimates store firststage
local beta_fs = _b[republicanjudge]

esttab firststage using "firststage_table.tex", ///
    label replace se star(* 0.1 ** 0.05 *** 0.01) ///
    title("First Stage Regression") ///
    keep(republicanjudge severityofcrime) ///
    varlabels(republicanjudge "Republican Judge" severityofcrime "Severity of Crime") ///
    stats(r2 N, labels("R-squared" "Observations")) ///
    alignment(D{.}{.}{-1}) ///
    booktabs noobs
	
// reduced form regression
reg recidivates republicanjudge severityofcrime
local beta_rf = _b[republicanjudge]

// calculate ratio
display `beta_rf' / `beta_fs'

// IV regression
ivreg2 recidivates (monthsinjail = republicanjudge) severityofcrime
estimates store iv_stage2

esttab iv_stage2 using "iv_secondstage_table.tex", ///
    label replace se star(* 0.1 ** 0.05 *** 0.01) ///
    title("Second Stage IV Regression") ///
    keep(monthsinjail severityofcrime) ///
    varlabels(monthsinjail "Months in Jail" severityofcrime "Severity of Crime") ///
    stats(r2 N, labels("R-squared" "Observations")) ///
    alignment(D{.}{.}{-1}) ///
    booktabs noobs
	
// check interaction
reg monthsinjail republicanjudge severityofcrime republicanjudge#c.severityofcrime
