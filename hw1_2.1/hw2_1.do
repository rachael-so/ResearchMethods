// Load the data
import delimited "assignment1-research-methods.csv", delimiter(tab) clear
describe

// Run regression with gender covariate
reg calledback eliteschoolca~e malecandidate

// Create table
esttab using "output_table.rtf", replace b(3) se(3) star(* 0.1 ** 0.05 *** 0.01) ///
    title("Effect of Elite College and Gender on Job Callback") ///
    label mtitles("Elite College and Gender Effects") collabels(none) ///
    addnotes("Standard errors in parentheses", "Dependent variable: Job Callback")
