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



