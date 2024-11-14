/*-------------- Step 1 --------------*/
import delimited "vaping-ban-panel.csv", clear
describe

/*-------------- Step 2 --------------*/
egen ever_ban = max(vapingban), by(stateid) // group by vapingban novapingban
gen pre_treatment = year < 2021
gen pre_treatment_trend = pre_treatment * ever_ban // interaction term

eststo parallel_trends: reg lunghospitalizations pre_treatment_trend i.ever_ban i.year if year < 2021, cluster(stateid)

/*-------------- Step 3 --------------*/
preserve
collapse (mean) lunghospitalizations, by(year ever_ban)

// graph
twoway (line lunghospitalizations year if ever_ban == 1, lcolor(red) lwidth(medium) ///
        legend(label(1 "States with Ban"))) ///
       (line lunghospitalizations year if ever_ban == 0, lcolor(blue) lwidth(medium) ///
        legend(label(2 "States without Ban"))) ///
       , title("Difference-in-Differences: Lung Hospitalizations Over Time") ///
         ytitle("Average Lung Hospitalizations") xtitle("Year") legend(pos(11) ring(0)) ///
         xlabel(2010(2)2022)
restore

/*-------------- Step 4 --------------*/
gen post_treatment = year >= 2021
gen post_treatment_effect = post_treatment * vapingban

eststo dnd_regression: reg lunghospitalizations post_treatment_effect i.ever_ban i.year, cluster(stateid)

/*-------------- Step 5 --------------*/
esttab parallel_trends dnd_regression using "regression_results.rtf", replace ///
    b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Parallel Trends Test and Difference-in-Differences Regression Results") ///
    label collabels(none) ///
    mtitles("Parallel Trends Test" "Difference-in-Differences") ///
    addnotes("Standard errors in parentheses", "Dependent variable: Lung Hospitalizations") ///
    nonumber noobs

reg lunghospitalizations pre_treatment_trend i.stateid i.year, cluster(stateid)
testparm i.stateid
