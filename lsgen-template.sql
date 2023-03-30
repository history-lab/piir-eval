select '<View><Labels name="label" toName="text">';
with labels(value) as  
(select distinct entity_code 
   from piir_eval.results_view
   where entity_code is not null)
select xmlelement(name "Label", 
                  xmlattributes(value))::text
   from labels;
select '</Labels><Text name="text" value="$text"></Text></View>';
