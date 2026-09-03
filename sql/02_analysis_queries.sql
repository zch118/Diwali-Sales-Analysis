SELECT COUNT(*) FROM Diwali_Sales_Data;   -- 应该 11251

SELECT COUNT(*) FROM Diwali_Sales_Data WHERE Amount IS NULL;
--
#删除多于列
alter table diwali_sales_data
drop column Status;
alter table diwali_sales_data
drop column unnamed1;
#性别修改
update diwali_sales_data
set  Gender=case
    when gender='F' then 'Female'
    when Gender='M' then  'Male'
end;
#
-- 2.1 先预览转换效果（不改数据，只看）
SELECT Marital_Status,
       CASE WHEN Marital_Status=0 THEN 'No' ELSE 'Yes' END AS Shaadi
FROM diwali_sales_data;

-- 2.2 加新列并填值
ALTER TABLE diwali_sales_data ADD COLUMN Shaadi VARCHAR(5);

UPDATE diwali_sales_data
SET Shaadi = CASE WHEN Marital_Status=0 THEN 'No' ELSE 'Yes' END;

-- 2.3 删掉原来的数字列
ALTER TABLE diwali_sales_data DROP COLUMN Marital_Status;
#删除金额为空
select count(*)
from diwali_sales_data
where Amount is null ;
delete  from    diwali_sales_data
where Amount is null ;
SELECT  COUNT(*)
from diwali_sales_data;
#去重
alter  table  diwali_sales_data
add  column  id int
    auto_increment
    primary key  first ;
#
-- 5.1 加自增主键 id（给每行一个唯一编号）
ALTER TABLE diwali_sales_data ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- 5.2 查出哪些是重复（HAVING>1 即出现多次的组）
SELECT User_ID,Cust_name,Product_ID,Gender,Age,Product_Category,
       Occupation,Orders,Amount,Shaadi, COUNT(*) AS 次数
FROM diwali_sales_data
GROUP BY User_ID,Cust_name,Product_ID,Gender,Age,Product_Category,
         Occupation,Orders,Amount,Shaadi
HAVING COUNT(*) > 1;

-- 5.3 删除重复：同组里 id 大的删掉，只留 id 最小的一条
DELETE t1 FROM diwali_sales_data t1
INNER JOIN diwali_sales_data t2
  ON  t1.User_ID=t2.User_ID
  AND t1.Cust_name=t2.Cust_name
  AND t1.Product_ID=t2.Product_ID
  AND t1.Gender=t2.Gender
  AND t1.Age=t2.Age
  AND t1.Product_Category=t2.Product_Category
  AND t1.Occupation=t2.Occupation
  AND t1.Orders=t2.Orders
  AND t1.Amount=t2.Amount
  AND t1.Shaadi=t2.Shaadi
WHERE t1.id > t2.id;

SELECT COUNT(*) FROM diwali_sales_data;   -- 验证：11175

alter table diwali_sales_data
add  column  age_group2 varchar(10);
update diwali_sales_data
set  age_group2=case
    when Age<18 then '0-17'
when age between  18 and 25 then'18-25'
when age between  26 and 35 then '26-35'
when age between 36  and 45  then '36-45'
WHEN Age BETWEEN 46 AND 50 THEN '46-50'
    WHEN Age BETWEEN 51 AND 55 THEN '51-55'
    ELSE '55+' END;
#
select count(*)
from diwali_sales_data
where Amount is null ;
SELECT Gender, Shaadi, Age_Group2, COUNT(*)
FROM diwali_sales_data GROUP BY Gender, Shaadi, Age_Group2 LIMIT 10;
-- 1. 先确认 data1 是干净的好表（应返回 11175）
SELECT COUNT(*) FROM diwali_sales_data;

-- 2. 确认是11175后，删掉坏的旧表，再把data1改回正式名
DROP TABLE diwali_sales_data;
RENAME TABLE diwali_sales_data TO diwali_sales_data;
#男性与女性贡献额占比
select diwali_sales_data.Gender as 性别,
count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by  性别
order by  销售额占比;
##女性贡献了约 70% 销售额，是排灯节的绝对购买主力，男性仅 3 成。
#业务动作：广告素材、优惠券、选品风格、客服话术都以女性为核心；男性不作主攻，只作为 "女性给家人代购" 的延伸场景。
#那个年龄段最能买(26-35 独占 4 成，26-45 合计超 60%，是核心青壮年客群；0-17 与 55 + 合计不足 7%，非目标)
select diwali_sales_data.`Age Group` as 年龄段,
       count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by 年龄段
order by 销售额占比 desc;
#婚否与性别，谁是最值钱的人（女性两类合计 70%；未婚女性是最大单一客群。人群包优先投 26-35 女性，已婚女性主打家庭囤货、未婚女性主打悦己消费。）
select diwali_sales_data.Gender as 性别,
       diwali_sales_data.Shaadi as 婚否,
       count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by  性别,婚否
order by 销售额 desc;
#什么职业消费能力最强(IT / 医疗 / 航空 / 银行四大高薪职业合计约 48%，消费力集中在白领专业人群，投放聚焦职场圈层。)
select  diwali_sales_data.Occupation as 职业,
        count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by 职业
order by 销售额 desc ;
#那个州(邦)卖的最好(Top3 邦合计约 45%，销售高度集中；这些地区要提前备货、加物流仓、做区域活动，长尾邦以拉新为主)
select diwali_sales_data.State as 州,
        count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by  州
order by  销售额 desc
limit 10;
#五大区谁强谁弱(中部 + 南部占近 2/3，是主力市场；东部最弱，是潜力拓展区)
select diwali_sales_data.Zone as 大区,
         count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by  大区
order by  销售额 desc;
#顾客都买什么品类(食品一家独大（近 1/3），服装 / 鞋 / 电子构成第二梯队（各约 15%），四大品类合计约 77%；明年大促优先备这四类，尾部门类（Office/Veterinary）精简库存。）
select diwali_sales_data.Product_Category as 品类,
        count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by  品类
order by 销售额 desc ;
#年龄段*性别交叉(每个年龄段里女性都高于同段男性，26-35 岁女性是断层第一的核心客群—— 这就是整份画像最终锁定的 "那个人"。)
select  diwali_sales_data.`Age Group` as 年龄段,
        diwali_sales_data.Gender as 性别,
        count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by  年龄段,性别
order by  销售额 desc ;
#top10 畅销品(头部爆款要重点保库存、做关联推荐；对比销量与销售额可识别 "走量款" 和 "高价款"。)
select* from (
    select diwali_sales_data.Product_ID as 商品编号,
           sum(diwali_sales_data.Orders) as 件数,
           sum(diwali_sales_data.Amount) as 销售额,
           rank() over (order by sum(diwali_sales_data.Amount) desc) as 销售排名
    from diwali_sales_data
    group by  商品编号
             )t
where 销售排名<=10;
#top10高价值客户（这些是高频高额的超级用户，应给专属客服、会员权益、新品优先购，把她们变成口碑传播节点。）
select diwali_sales_data.User_ID as 用户编号,
       diwali_sales_data.Cust_name as 用户姓名,
        count(*) as 购买笔数,
sum(diwali_sales_data.Orders) as 商品件数,
sum(diwali_sales_data.Amount) as 销售额,
round(sum(diwali_sales_data.Amount)/(select sum(diwali_sales_data.Amount) from diwali_sales_data)*100,2) as 销售额占比
from diwali_sales_data
group by  用户编号,用户姓名
order by  销售额 desc
limit 10;
#方法二
SELECT * FROM (
    SELECT User_ID AS 客户编号, ANY_VALUE(Cust_name) AS 姓名,
           COUNT(*) AS 购买笔数,
           SUM(Amount) AS 累计消费,
           RANK() OVER(ORDER BY SUM(Amount) DESC) AS 客户排名
    FROM diwali_sales_data
    GROUP BY User_ID
) t
WHERE 客户排名 <= 10;
---总销售 1.057 亿、3752 客户；核心客群 = 26-35 岁、IT / 医疗 / 航空行业、中部南部及北方邦的女性；主力品类 = 食品 / 服装 / 鞋 / 电子；并锁定了 Top 商品和 Top10 VIP 客户。


















