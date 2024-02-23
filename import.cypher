// Product
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/products.csv" AS row
CREATE (n:Product)
SET n = row,
n.unitPrice = toFloat(row.unitPrice),
n.unitsInStock = toInteger(row.unitsInStock), n.unitsOnOrder = toInteger(row.unitsOnOrder),
n.reorderLevel = toInteger(row.reorderLevel), n.discontinued = (row.discontinued <> "0");

// Category
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/categories.csv" AS row
CREATE (n:Category)
SET n = row;

// Supplier
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/suppliers.csv" AS row
CREATE (n:Supplier)
SET n = row;

CREATE INDEX IF NOT EXISTS FOR (p:Product) ON (p.productID);
// Use vector index on productName
CREATE INDEX IF NOT EXISTS FOR (p:Product) ON (p.productName);
CREATE INDEX IF NOT EXISTS FOR (c:Category) ON (c.categoryID);
CREATE INDEX IF NOT EXISTS FOR (s:Supplier) ON (s.supplierID);

// Relationships
MATCH (p:Product),(c:Category)
WHERE p.categoryID = c.categoryID
CREATE (p)-[:PART_OF]->(c);

MATCH (p:Product),(s:Supplier)
WHERE p.supplierID = s.supplierID
CREATE (s)-[:SUPPLIES]->(p);

// Customer
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/customers.csv" AS row
CREATE (n:Customer)
SET n = row;

// Order
LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/orders.csv" AS row
CREATE (n:Order)
SET n = row;

CREATE INDEX IF NOT EXISTS FOR (n:Customer) ON (n.customerID);
CREATE INDEX IF NOT EXISTS FOR (o:Order) ON (o.orderID);

// Relationships
MATCH (n:Customer),(o:Order)
WHERE n.customerID = o.customerID
CREATE (n)-[:PURCHASED]->(o);

LOAD CSV WITH HEADERS FROM "https://data.neo4j.com/northwind/order-details.csv" AS row
MATCH (p:Product), (o:Order)
WHERE p.productID = row.productID AND o.orderID = row.orderID
CREATE (o)-[details:ORDERS]->(p)
SET details = row,
details.quantity = toInteger(row.quantity);
