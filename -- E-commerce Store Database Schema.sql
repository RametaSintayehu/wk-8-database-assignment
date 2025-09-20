-- E-commerce Store Database Schema
-- Single SQL file with CREATE DATABASE and CREATE TABLE statements.
-- Designed for MySQL (InnoDB).
-- Date: 2025-09-19

DROP DATABASE IF EXISTS `ecommerce_store`;
CREATE DATABASE `ecommerce_store` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ecommerce_store`;

/*
TABLE: customers
- Stores user/customer accounts.
*/
CREATE TABLE `customers` (
`customer_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`email` VARCHAR(255) NOT NULL,
`password_hash` VARCHAR(255) NOT NULL,
`first_name` VARCHAR(100) NOT NULL,
`last_name` VARCHAR(100) NOT NULL,
`phone` VARCHAR(20) DEFAULT NULL,
`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
`updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (`customer_id`),
UNIQUE KEY `uk_customers_email` (`email`)
) ENGINE=InnoDB;

/*
TABLE: addresses
- One customer can have many addresses (one-to-many)
*/
CREATE TABLE `addresses` (
`address_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`customer_id` INT UNSIGNED NOT NULL,
`line1` VARCHAR(255) NOT NULL,
`line2` VARCHAR(255) DEFAULT NULL,
`city` VARCHAR(100) NOT NULL,
`state` VARCHAR(100) DEFAULT NULL,
`postal_code` VARCHAR(20) DEFAULT NULL,
`country` VARCHAR(100) NOT NULL,
`is_primary` TINYINT(1) NOT NULL DEFAULT 0,
PRIMARY KEY (`address_id`),
KEY `idx_addresses_customer` (`customer_id`),
CONSTRAINT `fk_addresses_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


/*
TABLE: categories
- Product categories (self-referencing parent-child relationship allowed)
*/
CREATE TABLE `categories` (
`category_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL,
`parent_id` INT UNSIGNED DEFAULT NULL,
PRIMARY KEY (`category_id`),
UNIQUE KEY `uk_categories_name` (`name`),
CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories`(`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

/*
TABLE: categories
- Product categories (self-referencing parent-child relationship allowed)
*/
CREATE TABLE `categories` (
`category_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL,
`parent_id` INT UNSIGNED DEFAULT NULL,
PRIMARY KEY (`category_id`),
UNIQUE KEY `uk_categories_name` (`name`),
CONSTRAINT `fk_categories_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories`(`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

/*
`billing_address_id` INT UNSIGNED DEFAULT NULL,
PRIMARY KEY (`order_id`),
KEY `idx_orders_customer` (`customer_id`),
CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT `fk_orders_shipping_address` FOREIGN KEY (`shipping_address_id`) REFERENCES `addresses`(`address_id`) ON DELETE SET NULL ON UPDATE CASCADE,
CONSTRAINT `fk_orders_billing_address` FOREIGN KEY (`billing_address_id`) REFERENCES `addresses`(`address_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

/*
TABLE: order_items
- Many-to-many between orders and products with extra fields (quantity, unit_price)
*/
CREATE TABLE `order_items` (
`order_id` INT UNSIGNED NOT NULL,
`product_id` INT UNSIGNED NOT NULL,
`quantity` INT UNSIGNED NOT NULL DEFAULT 1,
`unit_price` DECIMAL(10,2) NOT NULL,
PRIMARY KEY (`order_id`, `product_id`),
KEY `idx_oi_product` (`product_id`),
CONSTRAINT `fk_oi_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT `fk_oi_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT `chk_order_items_quantity` CHECK (`quantity` > 0)
) ENGINE=InnoDB;

/*
TABLE: payments
- Payments may be multiple per order (installments, partial refunds, etc.)
*/
CREATE TABLE `payments` (
`payment_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`order_id` INT UNSIGNED NOT NULL,
`amount` DECIMAL(10,2) NOT NULL,
`method` VARCHAR(50) NOT NULL,
`status` ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
`transaction_id` VARCHAR(255) DEFAULT NULL,
`paid_at` TIMESTAMP NULL DEFAULT NULL,
PRIMARY KEY (`payment_id`),
KEY `idx_payments_order` (`order_id`),
CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

/*
TABLE: reviews
- Customer product reviews; one customer can only review a product once
*/
CREATE TABLE `reviews` (
`review_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
`product_id` INT UNSIGNED NOT NULL,
`customer_id` INT UNSIGNED NOT NULL,
`rating` TINYINT UNSIGNED NOT NULL,
`comment` TEXT,
`created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`review_id`),
KEY `idx_reviews_product` (`product_id`),
CONSTRAINT `fk_reviews_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT `fk_reviews_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT `uk_reviews_product_customer` UNIQUE (`product_id`, `customer_id`),
CONSTRAINT `chk_reviews_rating` CHECK (`rating` >= 1 AND `rating` <= 5)
) ENGINE=InnoDB;


-- End of schema


/*
Notes:
- The schema models common relationships:
* One-to-many: customers -> addresses, customers -> orders, products -> product_images
* Many-to-many: products <-> categories (product_categories), products <-> warehouses (stock_levels)
* One-to-one: [not strictly enforced here; could model customer->profile]
- Application logic (for example: ensuring only one primary address per customer) is typically enforced at the application level or via triggers.
- MySQL's CHECK constraints are enforced in recent versions (8.0+). If using older MySQL, some CHECKs are parsed but not enforced.
*/