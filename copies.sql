\copy (select * from piir_eval.cm_compare) to 'results/cm_compare.csv' with format csv header 
\copy (select * from piir_eval.results_view) to 'results/results.csv' csv header 
\copy (select * from piir_eval.ground_truth_view) to 'results/gt.csv' csv header
\copy (select * from piir_eval.comparisons) to 'results/comparisons.csv' csv header 