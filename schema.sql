create schema if not exists piir_eval;
create table if not exists piir_eval.tests 
    (test_id int generated always as identity primary key,
     doc_id  text not null, 
     corpus  text not null);
create table if not exists piir_eval.entities 
    (entity_code text primary key,
     description text not null);
create table if not exists piir_eval.methods 
    (method_code text primary key,
     description text not null);
create table if not exists piir_eval.results 
    (result_id   int generated always as identity primary key,
     test_id     int  not null references piir_eval.tests,
     entity_code text not null references piir_eval.entities,
     method_code text not null references piir_eval.methods,
     entity_text text not null,
     start_idx   int  not null,
     end_idx     int  not null);