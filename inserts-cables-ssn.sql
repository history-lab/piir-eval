-- add methods
insert into piir_eval.methods(method_code, description) 
values ('capone', 'Capital One Data Profiler'),
       ('muckrock', 'Common Rexeg library used in the documentcloud add on');

-- add entities
insert into piir_eval.entities(entity_code, description) 
values ('ban', 'Bank account number, 10-18 digits'),
       ('credit_card', 'Credit card bumber'),
       ('drivers_license', 'Drivers license'),
       ('ssn','Social security number'),
       ('phone_number','Phone number');
       -- ('address','address'),
       -- ('person','person''s name'),
       -- ('email_address','Email address'),
       -- ('url','URL'),
       -- ('uuid','UUID'),
       -- ('hash_or_key','md5, sha1, sha256, random hash, etc.'),
       -- ('ipv4','IP address, version 4'),
       -- ('ipv6','IP address, version 6'),
       -- ('mac_address','MAC address'),

-- first pass for tasks, add all the cases from cables
insert into piir_eval.tasksets (name) values ('cables-ssn'); 
insert into piir_eval.tasks (taskset_id, doc_id, corpus, body)
select (select taskset_id from piir_eval.tasksets where name = 'cables-ssn'),
        doc_id, 'cfpf', body
   from foiarchive.docs 
   where corpus = 'cfpf' and 
   body ~ '(?!000|666)[0-8][0-9]{2}-(?!00)[0-9]{2}-(?!0000)[0-9]{4}';


