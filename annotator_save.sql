create table natalie_ground_truth as select * from ground_truth_view;
create table natalie_comparisons as select * from comparisons;
create table natalie_scores as select * from scores;

-- cleanup
truncate table ground_truth;
truncate table ground_truth_stage;