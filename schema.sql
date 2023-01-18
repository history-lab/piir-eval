create schema if not exists piir_eval;
create table if not exists piir_eval.testsets
    (testset_id int generated always as identity primary key,
     name       text not null);
create table if not exists piir_eval.tests 
    (test_id      int generated always as identity primary key,
     testset_id   int not null references piir_eval.testsets,
     doc_id  text not null, 
     corpus  text not null,
     body    text not null);
create table if not exists piir_eval.entities 
    (entity_code text primary key,
     description text not null);
create table if not exists piir_eval.methods 
    (method_code text primary key,
     description text not null);
create table if not exists piir_eval.runs
    (run_id      int generated always as identity primary key,
     method_code text not null references piir_eval.methods,
     start_time  timestamp with time zone not null default current_timestamp);
create table if not exists piir_eval.testruns
    (testrun_id  int generated always as identity primary key,
     run_id      int references piir_eval.runs on delete cascade,
     test_id     int references piir_eval.tests,
     start_time  timestamp with time zone not null default current_timestamp,
     unique(run_id, test_id));
create table if not exists piir_eval.results 
    (result_id   int generated always as identity primary key,
     testrun_id  int not null  references piir_eval.testruns on delete cascade,
     entity_code text not null references piir_eval.entities,
     entity_text text not null,
     start_idx   int,
     end_idx     int);
create view piir_eval.results_view as
select r.method_code, r.run_id, tr.start_time, tr.test_id, 
       tr.testrun_id, t.doc_id, t.corpus,
       'http://history-lab.org/documents/' || t.doc_id docurl,
       res.result_id, res.entity_code, res.entity_text, 
       res.start_idx, res.end_idx
   from piir_eval.runs r join piir_eval.testruns tr 
                              on (r.run_id = tr.run_id)
                         join piir_eval.tests t
                              on (tr.test_id = t.test_id)
                         left join piir_eval.results res
                              on (tr.testrun_id = res.testrun_id)
   where r.run_id = (select max(run_id)
                      from piir_eval.runs
                      where method_code = r.method_code);
