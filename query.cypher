MATCH (p:Product)
CALL db.index.vector.queryNodes('product-name-embeddings', 5, $query)
YIELD node AS similarProduct, score
MATCH (similarProduct)
RETURN DISTINCT similarProduct.productName, score ORDER BY score DESC;
