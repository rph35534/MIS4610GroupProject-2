
# MIST 4610 Group Project #2 - Northline Outfitters

## Group Information
**Group Name:** [Your Group Name]

### Members and Roles
-  - Group Leader
-  - Conceptual Modeler
-  - Database Designer
-  - Data Wrangler
-  - SQL Writer

---

## Case Summary
Northline Outfitters is a small online retail company that sells student-friendly lifestyle and tech accessories such as hoodies, water bottles, desk lamps, phone cases, keyboards, mouse pads, and backpacks. The company purchases merchandise from outside vendors and sells directly to consumers in the United States and Canada.

This project focuses on turning messy spreadsheet data into a usable relational database. The provided data contains several issues, including inconsistent date formats, embedded customer information, mixed units of measurement, inconsistent tax and discount formatting, and duplicate-looking product records. Our goal was to clean the data, build a conceptual model, implement the database, import cleaned data, and write useful SQL queries.

---

## Data Model
<img width="777" height="446" alt="datamod2" src="https://github.com/user-attachments/assets/f93bda44-3abe-473e-a256-d71bffec8b87" />

#### Data Model Explanation
Customer

The Customer entity stores information about individuals who place orders. Attributes include customer ID, name, email, and customer type (e.g., student, loyalty, guest).

Primary Key: customer_id
This table was created to extract customer information from the messy customer_info field in the raw data.
Separating customers ensures that duplicate customer records are minimized and allows for tracking customer behavior across multiple orders.
Employee (Recursive Relationship)

The Employee entity stores employees who process orders.

Primary Key: employee_id
Foreign Key: manager_id (references Employee)

This table includes a recursive (self-referencing) relationship, where each employee can be linked to a manager who is also an employee.

This models the business structure where managers supervise employees.
It allows analysis such as comparing employee performance under the same manager (required query).
Order

The Order entity represents each transaction placed by a customer.

Primary Key: order_id
Foreign Keys:
customer_id → Customer
employee_id → Employee

Attributes include sale date, payment method, shipping details, return flag, and notes.

This entity captures order-level data and separates it from product-level details.
It ensures that each order is uniquely identified and linked to both a customer and an employee.
Order_Line (Associative Entity)

The Order_Line entity is a bridge table that connects Orders and Products.

Primary Key: line_id
Foreign Keys:
order_id → Order
sku → Product

Attributes include quantity, unit price, discount, tax, and line total.

This resolves the many-to-many relationship between Orders and Products:
One order can contain many products
One product can appear in many orders
It also stores transactional details specific to each product in an order.
Product

The Product entity stores all product-related information.

Primary Key: sku
Foreign Key: vendor_id → Vendor
Self-referencing FK: parent_sku

Attributes include description, category, cost, list price, reorder level, and physical characteristics.

The parent_sku supports product variants, which addresses duplicate-looking products in the raw data.
Separating products ensures consistency and prevents redundancy across orders.
Vendor

The Vendor entity stores supplier information.

Primary Key: vendor_id

Attributes include vendor name, phone, and representative.

This entity supports supply chain analysis and connects vendors to products.
It enables answering questions like which vendors supply products across multiple categories.

## Data Quality Assessment

The raw spreadsheet data contained several quality issues that had to be addressed before database implementation.

### Main Data Quality Issues
1. **Mixed date formats**
   - Some dates appeared in U.S. style while others followed Canadian formatting.
   - This created ambiguity in interpreting transaction dates.

2. **Embedded customer information**
   - The `customer_info` field combined multiple pieces of information into one field.
   - In some cases, it included the customer name plus notes such as "student," "loyalty customer," or "guest checkout."

3. **Inconsistent country and shipping data**
   - Country indicators were sometimes embedded in identifiers.
   - Shipping destination values were inconsistent, including actual locations and notes like "Same as billing" or "Dorm pickup."

4. **Mixed measurement units**
   - Size, weight, and dimension fields used both metric and imperial units.

5. **Inconsistent discount and tax formatting**
   - Discount values appeared as percentages, text, or raw numeric values.
   - Tax values were also inconsistently formatted.

6. **Duplicate-looking or variant product rows**
   - Some products appeared multiple times with small naming or formatting differences.
   - Some items may have represented product variants rather than entirely separate products.

7. **Inconsistent categorical values**
   - Payment methods, categories, return flags, and discontinued values were not always entered in a standard format.

8. **Missing or incomplete values**
   - Some rows contained blanks in fields such as email, alternate SKU, shipping data, or notes.

### Why These Issues Matter
These problems affect data consistency, make SQL analysis less reliable, and create difficulties when building normalized tables with clean keys and relationships.

---

## Data Cleaning Process

We cleaned the data before importing it into the database by standardizing formats, separating combined fields, and resolving inconsistent values.

### Cleaning Steps
1. Standardized date formats into a single database-friendly format
2. Split combined customer information into cleaner attributes where possible
3. Standardized country values to a consistent format
4. Standardized payment methods, return flags, discontinued values, and categories
5. Converted size/weight fields into more consistent units where appropriate
6. Cleaned discount and tax fields so values could be stored numerically
7. Reviewed duplicate-looking products and merged or documented them when justified
8. Trimmed spaces, corrected capitalization, and normalized text fields
9. Checked for missing values and handled them appropriately using NULLs or cleaning logic
10. Verified key fields such as SKU, order ID, employee reference, and vendor data before import

