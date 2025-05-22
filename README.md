# mysql_inventory_management_tracking_system
# My final assignment for the Power Learn Project Africa Scholarship Program Database Design Module 

# MySQL Inventory Tracking System

## Project Title
Inventory Tracking Database Management System using MySQL

## Description
This project implements a relational database for an Inventory Tracking System. It is designed to manage products, suppliers, warehouses, stock levels, customer orders, and purchase orders. The system allows for tracking inventory quantities across different warehouses, managing sales to customers, and procurement from suppliers.

Key features include:
- Management of suppliers, product categories, and products.
- Tracking of product inventory across multiple warehouses.
- Handling customer information and sales orders.
- Managing purchase orders to replenish stock.
- Recording stock adjustments for various reasons (e.g., damage, loss, corrections).
- Automatic calculation of order totals and purchase order subtotals using generated columns.
- Triggers to maintain data integrity and automate updates (e.g., updating total order amounts, adjusting inventory levels upon sales or stock receipts).

## How to Run/Setup the Project (Import SQL)

### Prerequisites
- MySQL Server is installed and running.
- A MySQL client (e.g., MySQL Command Line Client, MySQL Workbench, DBeaver, phpMyAdmin).

### Setup Instructions

1.  **Clone the Repository (Optional):**
    ```bash
    git clone [https://github.com/somog007/mysql_inventory_management_tracking_system.git](https://github.com/somog007/mysql_inventory_management_tracking_system.git)
    cd mysql_inventory_management_tracking_system
    ```

2.  **Create the Database and Import the SQL File:**

    You can use a MySQL client to import the `inventory_management.sql` file.

    **Option A: Using MySQL Command Line Client**

    a.  Open your terminal or command prompt.
    b.  Navigate to the directory where you saved `inventory_management.sql`.
    c.  Log in to MySQL (you will be prompted for your MySQL root or user password):
        ```bash
        mysql -u your_mysql_user -p
        ```
        Replace `your_mysql_user` with your MySQL username (e.g., `root`).
    d.  The `inventory_management.sql` script includes commands to create and use the database `inventory_db`. So, you can directly source the file:
        ```sql
        source path/to/your/inventory_management.sql;
        ```
        For example, if the file is in `C:\Users\YourUser\Downloads\`, the command would be `source C:/Users/YourUser/Downloads/inventory_management.sql;` (use forward slashes). If you are already in the directory containing the file, it's just `source inventory_management.sql;`.

    **Option B: Using MySQL Workbench**

    a.  Open MySQL Workbench and connect to your MySQL server.
    b.  In the menu, go to `File` > `Open SQL Script...`.
    c.  Navigate to and select the `inventory_management.sql` file.
    d.  The script will open in a new query tab.
    e.  Execute the script by clicking the lightning bolt icon (Execute SQL Script). The script is designed to create the database `inventory_db` if it doesn't exist and then create all the tables.

    **Option C: Using other GUI tools (like DBeaver, phpMyAdmin)**

    a.  Connect to your MySQL server.
    b.  Most tools provide an option to "Run SQL Script" or "Import" an SQL file.
    c.  Alternatively, you can open the `inventory_management.sql` file in a text editor, copy its content, paste it into a new SQL query window in your tool, and execute it. The script will create the database `inventory_db` and its tables.

3.  **Verify Installation:**
    After running the script, you can verify that the tables were created:
    ```sql
    USE inventory_db;
    SHOW TABLES;
    ```
    You should see a list of tables like `Suppliers`, `Products`, `Inventory`, `Orders`, etc.
    You can also check the structure of a specific table:
    ```sql
    DESCRIBE Products;
    ```
