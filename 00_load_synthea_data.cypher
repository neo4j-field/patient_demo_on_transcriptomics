CALL apoc.load.csv('observations.csv', {header:true, sep:',', nullValues:['null']}) 
    YIELD lineNo, map as row , list
        WITH row
      WHERE exists(row.ENCOUNTER) and row.ENCOUNTER <> ''
      WITH row, row.CODE as code, CASE row.TYPE WHEN 'text' THEN row.VALUE ELSE toFloat(row.VALUE) END as value
      WITH row, apoc.map.fromPairs([[code, value]]) as attr
      MATCH (p:Patient {id:row.PATIENT})
      MATCH (oe:Encounter {id:row.ENCOUNTER, isEnd: false})
      MERGE (oe) -[:HAS_OBSERVATION]-> (o:Observation )
      SET o += attr;