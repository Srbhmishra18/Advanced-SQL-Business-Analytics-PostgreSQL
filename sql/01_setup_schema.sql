-- creating separte schema for raw and analytics data
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

-- testing if the data is imported properly
SELECT 'orders' AS table, COUNT(*) FROM raw.orders
UNION ALL SELECT 'customers', COUNT(*) FROM raw.customers
UNION ALL SELECT 'order_items', COUNT(*) FROM raw.order_items
UNION ALL SELECT 'payments', COUNT(*) FROM raw.order_payments
UNION ALL SELECT 'products', COUNT(*) FROM raw.products
UNION ALL SELECT 'sellers', COUNT(*) FROM raw.sellers
UNION ALL SELECT 'geolocation', COUNT(*) FROM raw.geolocation
UNION ALL SELECT 'reviews', COUNT(*) FROM raw.order_reviews
UNION ALL SELECT 'category_translation', COUNT(*) FROM raw.category_translation;





 

