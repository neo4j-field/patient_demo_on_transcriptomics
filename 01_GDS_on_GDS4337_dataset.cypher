// drop graph
call gds.graph.drop('graph');
call gds.graph.drop('graph2');
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

CALL gds.nodeSimilarity.stats('graph', { relationshipWeightProperty: 'value', similarityCutoff: 0.9675 })
//YIELD node1, node2, similarity
YIELD similarityPairs, similarityDistribution
RETURN *;

// Calculating NodeSimilarity between patients in streaming mode
CALL gds.nodeSimilarity.stream('graph', { relationshipWeightProperty: 'value', similarityCutoff: 0.9675 })
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).patient_id AS Person1, gds.util.asNode(node2).patient_id AS Person2, similarity
ORDER BY Person1;

// Calculating NodeSimilarity between patients writing back mutateProperty
// not needed if straight write
CALL gds.nodeSimilarity.mutate('graph', { relationshipWeightProperty: 'value', similarityCutoff: 0.9675, mutateProperty:'similarity', mutateRelationshipType:'IS_SIMILAR' });

// write NodeSimilarity
CALL gds.nodeSimilarity.write('graph', {
    relationshipWeightProperty: 'value',
    similarityCutoff: 0.9708,
    writeRelationshipType: 'SIMILAR',
    writeProperty: 'similarityScore'
});
//YIELD nodesCompared, relationshipsWritten;

CALL gds.graph.project(
    'graph2',                                                                                
    ['Patient']  
    ,
    {SIMILAR: {orientation: 'UNDIRECTED'}},
    {relationshipProperties: ['similarityScore']}                         
);

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


CALL gds.graph.project(
    'graph2',   {                                                                               
    Patient: {properties: {hba1c: {defaultValue: 0.0}}}  
}
    ,
    {SIMILAR: {orientation: 'UNDIRECTED'}},
    {relationshipProperties: ['similarityScore']}                         
);

CALL gds.fastRP.write('graph2',{
    relationshipTypes:['SIMILAR'],
    featureProperties: ['hba1c'], //1 node features
    embeddingDimension: 128,
    iterationWeights: [0, 0, 1.0, 1.0],
    normalizationStrength:0.05,
propertyRatio: 0.5,
    writeProperty: 'fastRP__Embed'
})



CALL gds.beta.pipeline.nodeClassification.create('pipe')

CALL gds.beta.pipeline.nodeClassification.selectFeatures('pipe', ['fastRP__Embed'])
YIELD name, featureProperties

CALL gds.beta.pipeline.nodeClassification.configureSplit('pipe', {
  testFraction: 0.2,
   validationFolds: 5
 })
 YIELD splitConfig

// model
 CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('pipe', {penalty: 0.0625}) YIELD parameterSpace

