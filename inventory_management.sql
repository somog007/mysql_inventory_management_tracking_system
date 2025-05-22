-- inventory_management.sql
-- SQL script to create the database schema for an Inventory Tracking System

SET FOREIGN_KEY_CHECKS=0;
DROP DATABASE IF EXISTS `inventory_db`;
CREATE DATABASE IF NOT EXISTS `inventory_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `inventory_db`;

-- Table structure for table `Suppliers`
CREATE TABLE `Suppliers` (
  `supplier_id` INT AUTO_INCREMENT PRIMARY KEY,
  `supplier_name` VARCHAR(255) NOT NULL UNIQUE,
  `contact_name` VARCHAR(255) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `email` VARCHAR(255) DEFAULT NULL UNIQUE,
  `address` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_supplier_name` (`supplier_name`)
);

-- Table structure for table `Categories`
CREATE TABLE `Categories` (
  `category_id` INT AUTO_INCREMENT PRIMARY KEY,
  `category_name` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_category_name` (`category_name`)
);

-- Table structure for table `Products`
CREATE TABLE `Products` (
  `product_id` INT AUTO_INCREMENT PRIMARY KEY,
  `product_name` VARCHAR(255) NOT NULL,
  `sku` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Stock Keeping Unit',
  `description` TEXT DEFAULT NULL,
  `category_id` INT DEFAULT NULL,
  `supplier_id` INT DEFAULT NULL,
  `unit_price` DECIMAL(10, 2) NOT NULL COMMENT 'Purchase price from supplier',
  `reorder_level` INT DEFAULT 0 COMMENT 'Minimum quantity before reordering',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_unit_price` CHECK (`unit_price` >= 0),
  CONSTRAINT `fk_product_category` FOREIGN KEY (`category_id`) REFERENCES `Categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_product_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `Suppliers` (`supplier_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX `idx_product_name` (`product_name`),
  INDEX `idx_sku` (`sku`)
);

-- Table structure for table `Warehouses`
CREATE TABLE `Warehouses` (
  `warehouse_id` INT AUTO_INCREMENT PRIMARY KEY,
  `warehouse_name` VARCHAR(150) NOT NULL UNIQUE,
  `location` VARCHAR(255) DEFAULT NULL,
  `manager_name` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_warehouse_name` (`warehouse_name`)
);

-- Table structure for table `Inventory`
CREATE TABLE `Inventory` (
  `inventory_id` INT AUTO_INCREMENT PRIMARY KEY,
  `product_id` INT NOT NULL,
  `warehouse_id` INT NOT NULL,
  `quantity_on_hand` INT NOT NULL DEFAULT 0,
  `last_stocktake_date` DATETIME DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_quantity_on_hand` CHECK (`quantity_on_hand` >= 0),
  CONSTRAINT `fk_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_inventory_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouses` (`warehouse_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  UNIQUE KEY `uq_product_warehouse` (`product_id`, `warehouse_id`)
);

-- Table structure for table `Customers`
CREATE TABLE `Customers` (
  `customer_id` INT AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `phone` VARCHAR(20) DEFAULT NULL,
  `address` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_customer_email` (`email`),
  INDEX `idx_customer_name` (`last_name`, `first_name`)
);

-- Table structure for table `Orders`
CREATE TABLE `Orders` (
  `order_id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT DEFAULT NULL,
  `order_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `order_status` ENUM('Pending', 'Processing', 'Awaiting Payment', 'Awaiting Fulfillment', 'Shipped', 'Delivered', 'Cancelled', 'Refunded') NOT NULL DEFAULT 'Pending',
  `shipping_address` TEXT DEFAULT NULL,
  `billing_address` TEXT DEFAULT NULL,
  `total_amount` DECIMAL(12, 2) DEFAULT 0.00,
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_total_amount_orders` CHECK (`total_amount` >= 0),
  CONSTRAINT `fk_order_customer` FOREIGN KEY (`customer_id`) REFERENCES `Customers` (`customer_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX `idx_order_date` (`order_date`),
  INDEX `idx_order_status` (`order_status`)
);

-- Table structure for table `Order_Items`
CREATE TABLE `Order_Items` (
  `order_item_id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `warehouse_id` INT NOT NULL COMMENT 'Warehouse from which stock is allocated',
  `quantity_ordered` INT NOT NULL,
  `unit_sale_price` DECIMAL(10, 2) NOT NULL COMMENT 'Price per unit at the time of sale',
  `item_total` DECIMAL(12,2) GENERATED ALWAYS AS (`quantity_ordered` * `unit_sale_price`) STORED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_quantity_ordered_sales` CHECK (`quantity_ordered` > 0),
  CONSTRAINT `chk_unit_sale_price` CHECK (`unit_sale_price` >= 0),
  CONSTRAINT `fk_orderitem_order` FOREIGN KEY (`order_id`) REFERENCES `Orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_orderitem_product` FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_orderitem_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouses` (`warehouse_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY `uq_order_product` (`order_id`, `product_id`)
);

-- Table structure for table `Purchase_Orders`
CREATE TABLE `Purchase_Orders` (
  `po_id` INT AUTO_INCREMENT PRIMARY KEY,
  `supplier_id` INT NOT NULL,
  `warehouse_id` INT NOT NULL,
  `order_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expected_delivery_date` DATETIME DEFAULT NULL,
  `status` ENUM('Draft', 'Pending Approval', 'Approved', 'Ordered', 'Partially Received', 'Received', 'Cancelled') NOT NULL DEFAULT 'Draft',
  `total_cost` DECIMAL(12, 2) DEFAULT 0.00,
  `shipping_cost` DECIMAL(10,2) DEFAULT 0.00,
  `taxes` DECIMAL(10,2) DEFAULT 0.00,
  `notes` TEXT DEFAULT NULL,
  `created_by_user_id` INT DEFAULT NULL,
  `approved_by_user_id` INT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_total_cost_po` CHECK (`total_cost` >= 0),
  CONSTRAINT `fk_po_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `Suppliers` (`supplier_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_po_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouses` (`warehouse_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX `idx_po_status` (`status`),
  INDEX `idx_po_order_date` (`order_date`)
);

-- Table structure for table `Purchase_Order_Items`
CREATE TABLE `Purchase_Order_Items` (
  `po_item_id` INT AUTO_INCREMENT PRIMARY KEY,
  `po_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity_ordered` INT NOT NULL,
  `unit_cost` DECIMAL(10, 2) NOT NULL COMMENT 'Cost per unit from supplier for this PO',
  `quantity_received` INT DEFAULT 0,
  `received_date` DATETIME DEFAULT NULL,
  `item_subtotal` DECIMAL(12,2) GENERATED ALWAYS AS (`quantity_ordered` * `unit_cost`) STORED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT `chk_quantity_ordered_po` CHECK (`quantity_ordered` > 0),
  CONSTRAINT `chk_unit_cost_po` CHECK (`unit_cost` >= 0),
  CONSTRAINT `chk_quantity_received_po` CHECK (`quantity_received` >= 0 AND `quantity_received` <= `quantity_ordered`),
  CONSTRAINT `fk_poitem_po` FOREIGN KEY (`po_id`) REFERENCES `Purchase_Orders` (`po_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_poitem_product` FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY `uq_po_product` (`po_id`, `product_id`)
);

-- Table structure for table `Stock_Adjustments`
CREATE TABLE `Stock_Adjustments` (
    `adjustment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id` INT NOT NULL,
    `warehouse_id` INT NOT NULL,
    `adjustment_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `adjustment_type` ENUM('Increase', 'Decrease', 'Stocktake Correction', 'Damage', 'Loss', 'Found') NOT NULL,
    `quantity_adjusted` INT NOT NULL,
    `reason` TEXT DEFAULT NULL,
    `adjusted_by_user_id` INT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT `fk_adj_product` FOREIGN KEY (`product_id`) REFERENCES `Products` (`product_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `fk_adj_warehouse` FOREIGN KEY (`warehouse_id`) REFERENCES `Warehouses` (`warehouse_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_adj_date` (`adjustment_date`),
    INDEX `idx_adj_type` (`adjustment_type`)
);

-- Triggers

DELIMITER //

-- Update Orders.total_amount after Order_Items insert
CREATE TRIGGER `trg_after_order_item_insert`
AFTER INSERT ON `Order_Items`
FOR EACH ROW
BEGIN
    UPDATE `Orders`
    SET `total_amount` = (SELECT IFNULL(SUM(`item_total`),0) FROM `Order_Items` WHERE `order_id` = NEW.order_id)
    WHERE `order_id` = NEW.order_id;
END;
//

-- Update Orders.total_amount after Order_Items update
CREATE TRIGGER `trg_after_order_item_update`
AFTER UPDATE ON `Order_Items`
FOR EACH ROW
BEGIN
    UPDATE `Orders`
    SET `total_amount` = (SELECT IFNULL(SUM(`item_total`),0) FROM `Order_Items` WHERE `order_id` = NEW.order_id)
    WHERE `order_id` = NEW.order_id;
END;
//

-- Update Orders.total_amount after Order_Items delete
CREATE TRIGGER `trg_after_order_item_delete`
AFTER DELETE ON `Order_Items`
FOR EACH ROW
BEGIN
    UPDATE `Orders`
    SET `total_amount` = (SELECT IFNULL(SUM(`item_total`),0) FROM `Order_Items` WHERE `order_id` = OLD.order_id)
    WHERE `order_id` = OLD.order_id;
END;
//

-- Update Purchase_Orders.total_cost after Purchase_Order_Items insert
CREATE TRIGGER `trg_after_po_item_insert`
AFTER INSERT ON `Purchase_Order_Items`
FOR EACH ROW
BEGIN
    UPDATE `Purchase_Orders`
    SET `total_cost` = (SELECT IFNULL(SUM(`item_subtotal`),0) FROM `Purchase_Order_Items` WHERE `po_id` = NEW.po_id)
    WHERE `po_id` = NEW.po_id;
END;
//

-- Update Purchase_Orders.total_cost after Purchase_Order_Items update
CREATE TRIGGER `trg_after_po_item_update`
AFTER UPDATE ON `Purchase_Order_Items`
FOR EACH ROW
BEGIN
    UPDATE `Purchase_Orders`
    SET `total_cost` = (SELECT IFNULL(SUM(`item_subtotal`),0) FROM `Purchase_Order_Items` WHERE `po_id` = NEW.po_id)
    WHERE `po_id` = NEW.po_id;
END;
//

-- Update Purchase_Orders.total_cost after Purchase_Order_Items delete
CREATE TRIGGER `trg_after_po_item_delete`
AFTER DELETE ON `Purchase_Order_Items`
FOR EACH ROW
BEGIN
    UPDATE `Purchase_Orders`
    SET `total_cost` = (SELECT IFNULL(SUM(`item_subtotal`),0) FROM `Purchase_Order_Items` WHERE `po_id` = OLD.po_id)
    WHERE `po_id` = OLD.po_id;
END;
//

-- Update inventory when stock is received via Purchase Order Item
CREATE TRIGGER `trg_after_po_item_receive`
AFTER UPDATE ON `Purchase_Order_Items`
FOR EACH ROW
BEGIN
    DECLARE warehouse_for_po INT;
    IF NEW.quantity_received > OLD.quantity_received AND NEW.received_date IS NOT NULL THEN
        SELECT `warehouse_id` INTO warehouse_for_po FROM `Purchase_Orders` WHERE `po_id` = NEW.po_id;
        INSERT INTO `Inventory` (`product_id`, `warehouse_id`, `quantity_on_hand`, `last_stocktake_date`)
        VALUES (NEW.product_id, warehouse_for_po, NEW.quantity_received - OLD.quantity_received, NOW())
        ON DUPLICATE KEY UPDATE
        `quantity_on_hand` = `quantity_on_hand` + (NEW.quantity_received - OLD.quantity_received),
        `updated_at` = NOW();
    END IF;
END;
//

-- Deduct stock from inventory when an order item is created
CREATE TRIGGER `trg_after_order_item_created_deduct_stock`
AFTER INSERT ON `Order_Items`
FOR EACH ROW
BEGIN
    UPDATE `Inventory`
    SET `quantity_on_hand` = `quantity_on_hand` - NEW.quantity_ordered,
        `updated_at` = NOW()
    WHERE `product_id` = NEW.product_id AND `warehouse_id` = NEW.warehouse_id;
END;
//

-- Return stock to inventory if an order is cancelled
CREATE TRIGGER `trg_after_order_status_cancelled_add_stock`
AFTER UPDATE ON `Orders`
FOR EACH ROW
BEGIN
    IF OLD.order_status != 'Cancelled' AND NEW.order_status = 'Cancelled' THEN
        UPDATE `Inventory` i
        JOIN `Order_Items` oi ON i.product_id = oi.product_id AND i.warehouse_id = oi.warehouse_id
        SET i.quantity_on_hand = i.quantity_on_hand + oi.quantity_ordered,
            i.updated_at = NOW()
        WHERE oi.order_id = NEW.order_id;
    END IF;
END;
//

-- Adjust inventory after stock adjustment
CREATE TRIGGER `trg_after_stock_adjustment`
AFTER INSERT ON `Stock_Adjustments`
FOR EACH ROW
BEGIN
    DECLARE qty_change INT;
    SET qty_change = NEW.quantity_adjusted;
    IF NEW.adjustment_type IN ('Decrease', 'Damage', 'Loss') THEN
        SET qty_change = -1 * ABS(qty_change);
    END IF;
    INSERT INTO `Inventory` (`product_id`, `warehouse_id`, `quantity_on_hand`, `last_stocktake_date`)
    VALUES (NEW.product_id, NEW.warehouse_id, qty_change, NOW())
    ON DUPLICATE KEY UPDATE
    `quantity_on_hand` = `quantity_on_hand` + qty_change,
    `updated_at` = NOW();
END;
//

DELIMITER ;

SET FOREIGN_KEY_CHECKS=1;

-- End of SQL Script