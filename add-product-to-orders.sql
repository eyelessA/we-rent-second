INSERT INTO orders (product_id)
VALUES (2)
RETURNING product_id;

UPDATE products
SET quantity = quantity - 1
WHERE id = (SELECT product_id FROM orders ORDER BY created_at DESC LIMIT 1);