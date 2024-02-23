// Product
LOAD CSV WITH HEADERS FROM "file:///products-embeddings.csv" AS row
CREATE (n:Product)
SET n = row,
n.unitPrice = toFloat(row.unitPrice),
n.unitsInStock = toInteger(row.unitsInStock), n.unitsOnOrder = toInteger(row.unitsOnOrder),
n.reorderLevel = toInteger(row.reorderLevel), n.discontinued = (row.discontinued <> "0"),
n.productNameEmbedding = toFloatList(split(row.productNameEmbedding, ","));

// Category
LOAD CSV WITH HEADERS FROM "file:///categories.csv" AS row
CREATE (n:Category)
SET n = row;

// Supplier
LOAD CSV WITH HEADERS FROM "file:///suppliers.csv" AS row
CREATE (n:Supplier)
SET n = row;

CREATE INDEX `product-id` IF NOT EXISTS FOR (p:Product) ON (p.productID);
CREATE VECTOR INDEX `product-name-embeddings` IF NOT EXISTS
FOR (n: Product) ON (n.productNameEmbedding)
OPTIONS {indexConfig: {
 `vector.dimensions`: 1536,
 `vector.similarity_function`: 'cosine'
}};
CREATE INDEX `category-id` IF NOT EXISTS FOR (c:Category) ON (c.categoryID);
CREATE INDEX `supplier-id` IF NOT EXISTS FOR (s:Supplier) ON (s.supplierID);

// Relationships
MATCH (p:Product),(c:Category)
WHERE p.categoryID = c.categoryID
CREATE (p)-[:PART_OF]->(c);

MATCH (p:Product),(s:Supplier)
WHERE p.supplierID = s.supplierID
CREATE (s)-[:SUPPLIES]->(p);

// Customer
LOAD CSV WITH HEADERS FROM "file:///customers.csv" AS row
CREATE (n:Customer)
SET n = row;

// Order
LOAD CSV WITH HEADERS FROM "file:///orders.csv" AS row
CREATE (n:Order)
SET n = row;

CREATE INDEX `customer-id` IF NOT EXISTS FOR (n:Customer) ON (n.customerID);
CREATE INDEX `order-id` IF NOT EXISTS FOR (o:Order) ON (o.orderID);

// Relationships
MATCH (n:Customer),(o:Order)
WHERE n.customerID = o.customerID
CREATE (n)-[:PURCHASED]->(o);

LOAD CSV WITH HEADERS FROM "file:///order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.productID = row.productID AND o.orderID = row.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity);
