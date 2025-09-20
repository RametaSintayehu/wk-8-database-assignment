# 🛒 E-commerce Store Database Schema

This project contains a **relational database schema** for an E-commerce Store, built in **MySQL (InnoDB)**.  
It supports core e-commerce features such as **customers, addresses, product categories, orders, payments, and reviews**.

---

## 📌 Features
- **Customers**: Manage user accounts with secure password storage.
- **Addresses**: Multiple shipping/billing addresses per customer.
- **Categories**: Nested categories with parent-child relationships.
- **Products & Orders**: Supports many-to-many relationships with order items.
- **Payments**: Handles multiple payments per order (installments, refunds).
- **Reviews**: Customers can rate and review products.

---

## 🏗️ Database Setup

1. Open **MySQL Workbench** (or your preferred client).
2. Run the SQL file:

```sql
SOURCE ecommerce_store.sql;
# wk-8-database-assignment
completed wk-8 final Assignment
