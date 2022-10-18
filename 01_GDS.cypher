// GDS 
// Create Graph catalog
CALL gds.graph.project(
    'graph',                                                                                
    ['Patient','Transcript']  
    ,
    {MEASURED: {orientation: 'REVERSE'}},
    {relationshipProperties: ['value']}                           
)
YIELD graphName, nodeProjection, nodeCount AS nodes, relationshipCount AS rels
RETURN graphName, nodeProjection.Patient AS patientProjection, nodes, rels;

// Calculating NodeSimilarity between patients in streaming mode
CALL gds.nodeSimilarity.stream('graph', { relationshipWeightProperty: 'value', similarityCutoff: 0.85 })
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).patient_id AS Person1, gds.util.asNode(node2).patient_id AS Person2, similarity
ORDER BY Person1;

// Calculating NodeSimilarity between patients writing back mutateProperty
CALL gds.nodeSimilarity.mutate('graph', { relationshipWeightProperty: 'value', similarityCutoff: 0.85, mutateProperty:'similarity', mutateRelationshipType:'IS_SIMILAR' })

// write NodeSimilarity
CALL gds.nodeSimilarity.write('graph', {
    similarityCutoff: 0.85,
    writeRelationshipType: 'SIMILAR',
    writeProperty: 'similarityScore'
})
YIELD nodesCompared, relationshipsWritten;

CALL gds.graph.project(
    'graph2',                                                                                
    ['Patient']  
    ,
    {SIMILAR: {orientation: 'UNDIRECTED'}},
    {relationshipProperties: ['similarityScore']};                          
)

// community detection
CALL gds.louvain.stream('graph2', 
{ relationshipWeightProperty: 'similarityScore'})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).name AS name, communityId, intermediateCommunityIds
ORDER BY name ASC;

CALL gds.louvain.write('graph2', 
{ relationshipWeightProperty: 'similarityScore', writeProperty:'community'});

// delete bidirectional relationships
MATCH (n)-[s:SIMILAR]->(m)
WHERE id(n) < id(m)
DELETE s;
# fastRP
CALL gds.fastRP.stream(
    'graph',
    {
        embeddingDimension: 10,
        randomSeed: 256,
        relationshipWeightProperty: 'value'
    }
)
YIELD nodeId, embedding