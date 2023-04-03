create table piir_eval.lsgen_dcml_data (
    data_id          int generated always as identity primary key,
    task_id          int  not null references piir_eval.tasks unique,
    pii_detected     boolean not null);
comment on table piir_eval.lsgen_dcml_data is 
    'Each row represents a task in COVID-19 DCML Label Studio data set';
comment on column piir_eval.lsgen_dcml_data.pii_detected is
    't - if identification tools detected PII, f - if not';
-- Randomly select 175 tasks each of which is associated with a unique DCML doc
-- where PII has been detected and the doc <= 5 pages
with tasks_pii(task_id) as
    (select distinct r.task_id
        from piir_eval.results_view r join covid19.dcml_training d
                                    on (r.doc_id::int = d.item_id)
        where r.taskset_name = 'dcml' and
              r.start_idx is not null and  -- PII exists
              d.pg_cnt <= 5)
insert into piir_eval.lsgen_dcml_data (task_id, pii_detected)
select task_id, 't'
    from tasks_pii
    order by random()
    limit 175;
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
insert into piir_eval.lsgen_dcml_data (task_id, pii_detected)
select task_id, 'f'
   from tasks_no_pii
   order by random()
   limit 50;


