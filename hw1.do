// Load the data
import delimited "assignment1-research-methods.csv", clear
describe

// Run regression to measure the effect of attending an elite school on callback rate
reg calledback eliteschoolca~e

// Create table with regression results
esttab using "output_table.rtf", replace b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Effect of Elite College on Job Callback") ///
    label mtitles("Elite College Effect") collabels(none) ///
    addnotes("Standard errors in parentheses", "Dependent variable: Job Callback")