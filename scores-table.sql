drop table if exists piir_eval.scores;
create table piir_eval.scores (
    score_id    int generated always as identity primary key,
    description text not null unique,
    tpr         int  not null,
    fpr         int  not null,
    fnr         int  not null,
    precision_redact  decimal,
    recall_redact     decimal,
    tpe         int  not null,
    fpe         int  not null,
    fne         int  not null,
    precision_entity  decimal,
    recall_entity     decimal);