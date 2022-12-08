// CREATE patient nodes
CALL apoc.load.csv('GDS4337_noMetadata.csv', {header:false, sep:'TAB', nullValues:['null'], limit:1}) 
    YIELD lineNo, map as row , list
UNWIND list as p
with p skip 2 
MERGE(pa:Patient{patient_id:p, source:'GDS4337'});

// mark type 2 diabetes patients
with ["GSM946745","GSM946761","GSM946739","GSM946738","GSM946746","GSM946747","GSM946711","GSM946760","GSM946710"] as t2d
unwind t2d as d
match(p:Patient{patient_id:d})
SET p:T2D;

// mark non diabetics
with ["GSM946701","GSM946703","GSM946704","GSM946706","GSM946708","GSM946709","GSM946712","GSM946720","GSM946722","GSM946753","GSM946762","GSM946707","GSM946721","GSM946719","GSM946716","GSM946751","GSM946740","GSM946741","GSM946718","GSM946737","GSM946742","GSM946749","GSM946702","GSM946713","GSM946723","GSM946736","GSM946705","GSM946715","GSM946726","GSM946727","GSM946748","GSM946756","GSM946724","GSM946733","GSM946734","GSM946754","GSM946700","GSM946714","GSM946729","GSM946731","GSM946743","GSM946744","GSM946730","GSM946755","GSM946717","GSM946725","GSM946728","GSM946752","GSM946757","GSM946758","GSM946759","GSM946732","GSM946750","GSM946735"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:NoT2D 

// mark HbA1c --
with ["GSM946701","GSM946703","GSM946704","GSM946706","GSM946708","GSM946709","GSM946712","GSM946720","GSM946722","GSM946753","GSM946762","GSM946745"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:NoHbA1c;
// set hba1c value
with ["GSM946707","GSM946721"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=4.3;

with ["GSM946719"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=4.5;

with ["GSM946716","GSM946751"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=4.6;

with ["GSM946740"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.0;

with ["GSM946741"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.2;

with ["GSM946718","GSM946737","GSM946742","GSM946749"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.3;

with ["GSM946702","GSM946713","GSM946723","GSM946736"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.4;

with ["GSM946705","GSM946715","GSM946726","GSM946727","GSM946748","GSM946756"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.5;

with ["GSM946724","GSM946733","GSM946734","GSM946754"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.6;

with ["GSM946700","GSM946714","GSM946729"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.8;

with ["GSM946731","GSM946743","GSM946744"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:lowHbA1c, p.hba1c=5.9;

with ["GSM946730","GSM946755"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=6.0;

with ["GSM946717"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=6.1;

with ["GSM946725","GSM946728","GSM946752","GSM946757","GSM946758","GSM946739"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=6.2;

with ["GSM946759"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=6.4;

with ["GSM946738","GSM946746","GSM946747"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=6.8;

with ["GSM946711"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=6.9;

with ["GSM946732","GSM946760"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=7.0;

with ["GSM946710"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=7.8;

with ["GSM946750"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=8.0;

with ["GSM946735"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=8.6;

with ["GSM946761"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p.hba1c=10.0;


// mark high HbA1c (6.0 - 10.0)
with ["GSM946730","GSM946755","GSM946717","GSM946725","GSM946728","GSM946752","GSM946757","GSM946758","GSM946739","GSM946759","GSM946738","GSM946746","GSM946747","GSM946711","GSM946732","GSM946760","GSM946710","GSM946750","GSM946735","GSM946761"] as nont2d
unwind nont2d as non
match(p:Patient{patient_id:non})
SET p:highHbA1c;

// CREATE Transcript nodes
CALL apoc.load.csv('GDS4337_noMetadata.csv', {header:true, sep:'TAB', nullValues:['null']}) 
    YIELD lineNo, map as row, list
MERGE(tr:Transcript{name:row['ID_REF'],synonym:row['IDENTIFIER'], source:'GDS4337'});

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

// diabetes class
match(n:Patient:NoT2D)  set n.targetProperty =0;
match(n:Patient:T2D)  set n.targetProperty =1;

// training and test set
//12 members test set
match(p:Patient:NoHbA1c) set p.isTrain = 0;
// 51 members training
match(p:Patient) where not p:NoHbA1c set p.isTrain = 1;