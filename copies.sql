\copy (select * from piir_eval.cm_compare) to 'cm_compare.csv' with format csv header 
\copy (select * from piir_eval.results_view) to 'results.csv' csv header 
\copy (select * from piir_eval.ground_truth_view) to 'gt.csv' csv header
\copy (select * from piir_eval.comparisons) to 'comparisons.csv' csv header 