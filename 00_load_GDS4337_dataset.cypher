// CREATE patient nodes
CALL apoc.load.csv('GDS4337_noMetadata.csv', {header:false, sep:'TAB', nullValues:['null'], limit:1}) 
    YIELD lineNo, map as row , list
UNWIND list as p
with p skip 2 
CREATE(pa:Patient{patient_id:p, source:'GDS4337'});

// CREATE Transcript nodes
CALL apoc.load.csv('GDS4337_noMetadata.csv', {header:true, sep:'TAB', nullValues:['null']}) 
    YIELD lineNo, map as row, list
CREATE(tr:Transcript{name:row['ID_REF'], source:'GDS4337'});

// CREATE relationships
CALL apoc.periodic.iterate('
CALL apoc.load.csv("GDS4337_noMetadata.csv", {header:true, sep:"TAB", nullValues:["null"]}) 
    YIELD lineNo, map as dict, list
    WITH keys(dict) as patients, dict 
    UNWIND patients as patient
    
    MATCH (p:Patient{patient_id:patient}),(tr:Transcript{name:dict["ID_REF"]}) 
    WHERE dict[patient] is not null
    RETURN p, tr, dict[patient] as value'
     //return p.patient_id as patientNO, dict['ID_REF'] as transcript, dict[patient]
     ,"CREATE(p)<-[:MEASURED{value:toFloat(value)}]-(tr)",
     {batchsize:10000}
);