# MIST 4610 – Group Project #2  
## Northline Outfitters: Data Cleaning, Modeling, and SQL Analysis

### Members and Roles
- Ryan Hooper – Group Leader  
- [Name] – Conceptual Modeler  
- [Name] – Database Designer  
- [Name] – Data Wrangler  
- [Name] – SQL Writer  

---

## Case Summary

Northline Outfitters is a small online retail company that sells student-focused lifestyle and technology accessories. The company currently stores much of its operational data in Excel spreadsheets, resulting in inconsistencies, duplication, and formatting issues.

The goal of this project was to transform messy, unstructured spreadsheet data into a clean, normalized relational database. This involved identifying data quality issues, cleaning and standardizing the data, designing a conceptual model, and writing SQL queries to answer key business questions.

---

## Conceptual Model

### ERD Diagram
<img width="769" height="447" alt="Screenshot 2026-04-24 at 4 26 38 PM" src="https://github.com/user-attachments/assets/b3d8565d-435d-4ba1-822c-2ed65f02c141"/>
### Explanation

The database was designed to represent the core operations of a retail business, including customers, orders, employees, and products.

### Key Entities

**Customer**
- Stores customer information such as name and loyalty status
- Eliminates repeated customer data across orders

**Employee**
- Stores employees who process orders
- Includes a self-referencing relationship to represent managers

**Order**
- Represents each transaction
- Linked to both a customer and an employee

**Order_Line**
- Bridge table between Order and Product
- Stores quantity, price, and transaction-level details

**Product**
- Stores product details such as SKU and category
- Supports product tracking and analysis

**Vendor**
- Stores supplier information
- Links vendors to products

---

### Relationships

- One Customer → Many Orders  
- One Employee → Many Orders  
- One Manager → Many Employees (recursive)  
- One Order → Many Order Lines  
- One Product → Many Order Lines  
- One Vendor → Many Products  

---
### Queries
Query #1
SELECT 
    o.order_nation,
    p.product_description,
    SUM(ol.line_total) AS total_sales_revenue
FROM Order_Line ol
JOIN Product p ON ol.sku = p.sku
JOIN Orders o ON ol.order_id = o.order_id
GROUP BY o.order_nation, p.product_description
ORDER BY o.order_nation, total_sales_revenue DESC;
This query groups sales revenue by country and product to show which items generated the most revenue in each market.

Query #2
SELECT 
    e.manager_id,
    e.employee_id,
    COUNT(DISTINCT o.order_id) AS orders_handled
FROM Employee e
JOIN Orders o ON e.employee_id = o.employee_id
GROUP BY e.manager_id, e.employee_id
ORDER BY e.manager_id, orders_handled DESC;
This query counts how many unique orders each employee handled and sorts employees within their manager group.

Query #3
SELECT 
    v.vendor_name,
    COUNT(DISTINCT p.category) AS category_count
FROM Vendor v
JOIN Product p ON v.vendor_id = p.vendor_id
GROUP BY v.vendor_name
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY category_count DESC;
This query finds vendors connected to more than one product category.

Query #4
SELECT 
    c.loyalty_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(ol.line_total) AS total_revenue
FROM Customer c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Order_Line ol ON o.order_id = ol.order_id
GROUP BY c.loyalty_status
ORDER BY total_revenue DESC;
This query compares total revenue and order count between loyal and non-loyal customers.

Query #5
SELECT 
    p.product_description,
    COUNT(ol.line_id) AS total_lines_sold,
    SUM(CASE WHEN ol.return_flag = 1 THEN 1 ELSE 0 END) AS total_returns
FROM Product p
JOIN Order_Line ol ON p.sku = ol.sku
GROUP BY p.product_description
ORDER BY total_returns DESC;
This query shows which products were returned most often.

Query #6
SELECT 
    DATE_FORMAT(o.sale_date, '%Y-%m') AS sales_month,
    SUM(ol.line_total) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM Orders o
JOIN Order_Line ol ON o.order_id = ol.order_id
GROUP BY DATE_FORMAT(o.sale_date, '%Y-%m')
ORDER BY sales_month;
This query groups orders by month and calculates total monthly revenue.

### Business Rules

- Each order must have one customer and one employee  
- Each order must contain at least one product  
- Products are supplied by vendors  
- Employees are grouped under managers  
- Order_Line resolves the many-to-many relationship between orders and products  

---

## Data Quality Assessment

The dataset contained several data quality issues:

- Trailing spaces in fields (e.g., "USA   ")
- Duplicate records (same order appearing multiple times)
- Repeated customer names with no unique identifier
- Orders appearing across multiple rows (line-level data)
- Embedded meaning in IDs (e.g., EM-202, EM-M03)
- Inconsistent categorical values (Loyal vs Not Loyal)

These issues made the data unsuitable for direct database use and required cleaning.

---

## Data Cleaning Process

### 1. Standardizing Text Fields



