-- ============================================================
-- Diwali Sales Analysis - 数据清洗脚本 (MySQL 8.0)
-- 原始数据: 11251行 x 15列, latin-1/windows-1252编码
-- 清洗后: 11175行 x 13列
-- ============================================================

-- 1. 创建数据库
CREATE DATABASE IF NOT EXISTS diwali DEFAULT CHARACTER SET utf8mb4;
USE diwali;

-- 2. 创建原始表（DataGrip导入CSV时字符集选 windows-1252）
CREATE TABLE IF NOT EXISTS diwali_raw (
    User_ID INT, Cust_name VARCHAR(100), Product_ID VARCHAR(50),
    Gender VARCHAR(10), `Age Group` VARCHAR(20), Age INT,
    Marital_Status INT, State VARCHAR(100), Zone VARCHAR(20),
    Occupation VARCHAR(50), Product_Category VARCHAR(100),
    Orders INT, Amount DECIMAL(12,2), Status VARCHAR(50), unnamed1 VARCHAR(50)
);

-- 3. 清洗: 删空列+字段转换+删空值, 创建干净表
CREATE TABLE IF NOT EXISTS diwali_sales_data AS
SELECT
    ROW_NUMBER() OVER (ORDER BY User_ID) AS id,
    User_ID, Cust_name, Product_ID,
    CASE Gender WHEN 'F' THEN 'Female' WHEN 'M' THEN 'Male' ELSE Gender END AS Gender,
    `Age Group`, Age, State, Zone, Occupation, Product_Category, Orders, Amount,
    CASE Marital_Status WHEN 0 THEN 'No' WHEN 1 THEN 'Yes' ELSE 'Unknown' END AS Shaadi
FROM diwali_raw
WHERE Amount IS NOT NULL;

-- 4. 自连接去重 (保留id最小的行, 删除64条重复)
DELETE t1 FROM diwali_sales_data t1
INNER JOIN diwali_sales_data t2
WHERE t1.id > t2.id
  AND t1.User_ID=t2.User_ID AND t1.Cust_name=t2.Cust_name
  AND t1.Product_ID=t2.Product_ID AND t1.Gender=t2.Gender
  AND t1.`Age Group`=t2.`Age Group` AND t1.Age=t2.Age
  AND t1.State=t2.State AND t1.Zone=t2.Zone
  AND t1.Occupation=t2.Occupation AND t1.Product_Category=t2.Product_Category
  AND t1.Orders=t2.Orders AND t1.Amount=t2.Amount AND t1.Shaadi=t2.Shaadi;

-- 5. 验证: 11175行, 总销售额105747556
SELECT COUNT(*) AS rows_count, SUM(Amount) AS total_sales FROM diwali_sales_data;
