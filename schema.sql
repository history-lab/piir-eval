create schema if not exists piir_eval;
create table if not exists piir_eval.tasksets
    (taskset_id int generated always as identity primary key,
     name       text not null);
create table if not exists piir_eval.tasks 
    (task_id      int generated always as identity primary key,
     taskset_id   int not null references piir_eval.tasksets,
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
create table if not exists piir_eval.taskruns
    (taskrun_id  int generated always as identity primary key,
     run_id      int references piir_eval.runs on delete cascade,
     task_id     int references piir_eval.tasks,
     start_time  timestamp with time zone not null default current_timestamp,
     unique(run_id, task_id));
create table if not exists piir_eval.results 
    (result_id   int generated always as identity primary key,
     taskrun_id  int not null  references piir_eval.taskruns on delete cascade,
     entity_code text not null references piir_eval.entities,
     entity_text text not null,
     start_idx   int not null,
     end_idx     int not null);
create table if not exists piir_eval.ground_truth
    (ground_truth_id  int generated always as identity primary key,
     task_id          int  not null references piir_eval.tasks,
     entity_code      text not null references piir_eval.entities,
     entity_text      text,
     start_idx        int not null,
     end_idx          int not null,
     label_studio_id  int not null,
     creator          text not null,
     completed        timestamp with time zone not null);
create table if not exists piir_eval.ground_truth_stage
    (label_studio_id  int,
     creator          text,
     completed        timestamp with time zone,
     doc              text,
     entity_code      text,
     entity_text      text,
     start_idx        int,
     end_idx          int);