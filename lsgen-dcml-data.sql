create table piir_eval.ls_dcml_data (
    data_id          int generated always as identity primary key,
    task_id          int  not null references piir_eval.tasks unique,
    pii_detected     boolean not null);
comment on table piir_eval.ls_dcml_data is 
    'Each row represents a task in COVID-19 DCML Label Studio data set';
comment on column piir_eval.ls_dcml_data.pii_detected is
    't - if identification tools detected PII, f - if not';
-- Randomly select 150 tasks each of which is associated with a unique DCML doc
-- where PII has been detected and the doc <= 5 pages
with tasks_pii(task_id) as
    (select distinct r.task_id
        from piir_eval.results_view r join covid19.dcml_training d
                                    on (r.doc_id::int = d.item_id)
        where r.taskset_name = 'dcml' and
              r.start_idx is not null and  -- PII exists
              d.pg_cnt <= 5)
insert into piir_eval.ls_dcml_data (task_id, pii_detected)
select task_id, 't'
    from tasks_pii
    order by random()
    limit 150;
-- Randomly select 50 tasks each of which is associated with a unique DCML doc
-- where PII has not been detected and the doc <= 5 pages
with tasks_no_pii(task_id) as
    (select distinct r.task_id
        from piir_eval.results_view r join covid19.dcml_training d
                                        on (r.doc_id::int = d.item_id)
        where r.taskset_name = 'dcml' and
              -- no PII detected
              r.start_idx is null and
              not exists (select 1 from piir_eval.results_view e
                            where e.task_id = r.task_id and
                                  e.start_idx is not null) and
              d.pg_cnt <= 5)
insert into piir_eval.ls_dcml_data (task_id, pii_detected)
select task_id, 'f'
   from tasks_no_pii
   order by random()
   limit 75;

create table piir_eval.ls_dcml_annotators(
    annotator_id    int generated always as identity primary key,
    name            text not null);
insert into piir_eval.ls_dcml_annotators(name) 
    values ('isobel'), ('jules'), ('natalie');

create table piir_eval.ls_dcml_annotation_assignments(
    annotator_id    int not null 
        references piir_eval.ls_dcml_annotators,
    data_id         int not null 
        references piir_eval.ls_dcml_data,
    primary key (annotator_id, data_id));
insert into piir_eval.ls_dcml_annotation_assignments 
    select 1, data_id from piir_eval.ls_dcml_data 
       where (data_id between   1 and 100) or -- pii redactions detects
             (data_id between 151 and 200)    -- no detections
    union
    select 2, data_id from piir_eval.ls_dcml_data 
       where (data_id between  51 and 150) or -- pii redactions detects
             (data_id between 176 and 225)    -- no detections
    union  
    select 3, data_id from piir_eval.ls_dcml_data 
       where (data_id between 101 and 150) or 
             (data_id between   1 and  50) or    -- pii redactions detects
             (data_id between 201 and 225) or  
             (data_id between 151 and 175);      -- no detections
-- sanity check queries
select p.name, 
       count(distinct a.data_id) docs, 
       count(d.pii_detected) 
            filter (where d.pii_detected) pii_detected,
       count(d.pii_detected) 
            filter (where not d.pii_detected) pii_not_detected 
   from piir_eval.ls_dcml_annotators p 
            join piir_eval.ls_dcml_annotation_assignments a 
                on (p.annotator_id = a.annotator_id)
            join piir_eval.ls_dcml_data d 
                on (a.data_id = d.data_id)
   group by p.name;

select task_id, count(*) assignees 
   from piir_eval.ls_dcml_annotators p 
            join piir_eval.ls_dcml_annotation_assignments a 
                on (p.annotator_id = a.annotator_id)
            join piir_eval.ls_dcml_data d 
                on (a.data_id = d.data_id)
   group by d.task_id;

