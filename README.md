
# MIST 4610 Group Project #2 - Northline Outfitters

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
1. Inconsistent Date Formats

The sale_date column contains multiple date formats, including:

10-11-2025 (numeric format)
Oct 17 25 (abbreviated text format)
October 5 25 (full text format)
June 11 2025 (mixed format)
Why this is a problem:
Prevents proper sorting, filtering, and date-based analysis
Cannot be directly stored as a DATE/DATETIME data type without conversion
2. Embedded and Unstructured Customer Data

The customer_info field contains multiple pieces of information in one column, such as:

"Mason Rivera; Loyalty? Y"
"Grace Hall | Student | US"
Issues:
Customer name, loyalty status, and student status are combined
Different delimiters used (;, |)
Inconsistent formatting
Why this is a problem:
Violates normalization (not atomic)
Makes it difficult to query customer attributes separately
3. Inconsistent Payment Method Formatting

The payment_method column contains inconsistent values:

VISA, visa
Cash
Interac
Why this is a problem:
Same payment type stored in multiple formats
Leads to incorrect grouping in queries
4. Mixed Currency and Numeric Formatting

Columns such as unit_price contain currency symbols and text:

USD 18.99
CAD 46.99

The line_total column contains:

$19.43
Missing values
Why this is a problem:
Prevents direct use as numeric data (DECIMAL)
Requires parsing before calculations can be performed
5. Inconsistent Discount Values

The discount column contains multiple formats:

10%
5
promo5
student 10%
Why this is a problem:
Mix of numeric, percentage, and text values
Cannot be used directly in calculations
Requires standardization into a numeric format
6. Inconsistent Tax Formatting

The tax column includes:

Percentages (13%, 8.25%)
Missing values (NULL)
Why this is a problem:
Needs conversion to decimal values for calculations
Missing values must be handled appropriately
7. Missing Values

Several fields contain NULL or missing values:

tax
line_total
size_or_weight
return_flag
notes
Why this is a problem:
Can cause errors in calculations and analysis
Must be handled using NULL logic or default values
8. Inconsistent Country Codes

The ship_country field contains:

US
CA
Why this is a problem:
Not standardized to full names (United States, Canada)
May cause confusion in reporting
9. Unstructured Shipping Information

The ship_to field contains inconsistent values:

"Same as billing"
"Toronto, ON"
"Seattle, WA"
Why this is a problem:
Mix of actual locations and notes
Difficult to separate into city/state attributes
10. Inconsistent Size/Weight Formatting

The size_or_weight column contains:

11"
11 inches
one size
NULL
Why this is a problem:
Mixed units and formats
Not suitable for numeric analysis or standardization
11. Return Flag Inconsistency

The return_flag column contains:

Y
N
NULL
Why this is a problem:
Needs to be standardized into a consistent format (e.g., 1/0 or Yes/No)
12. SKU and Identifier Formatting Issues

The dataset includes:

SKU values like SKU-C-1014, SKU-U-1015
Order IDs like UORD-1041, CORD-1003
Employee IDs like EMU-202, EMC-403
Why this is a problem:
Embedded meaning (country or type) inside IDs
May require parsing or standardization for analysis
13. Duplicate or Variant Product Records

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

