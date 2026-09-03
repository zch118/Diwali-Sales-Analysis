# Diwali Sales Analysis

印度排灯节电商销售数据分析，用 SQL 做清洗和查询，Python 做探索性分析，Excel 和 Power BI 做可视化看板。

## 项目背景

排灯节是印度最大的购物季，数据里有 11251 条订单记录。我想通过这些数据看清楚：主要客户是谁、哪些地区卖得好、什么品类最受欢迎，最后做一个能交互的 Dashboard。

## 用到的工具

- MySQL 8.0 — 数据清洗 + 业务查询
- Python（Pandas, Matplotlib, Seaborn）— 探索性分析
- Excel — 透视表 + 透视图 + 切片器交互看板
- Power BI — 可视化看板

## 数据情况

原始数据 11251 行 15 列，CSV 是 latin-1 编码，导入 MySQL 的时候要选 windows-1252 不然印度邦名会乱码。

清洗后剩 11175 行，主要做了这些：
- 删掉 Status 和 unnamed1 两个空列
- Amount 列有 12 个空值，整行删了
- 自连接去重，删了 64 条重复记录（MySQL 不能直接用 CTE 删除，所以用自连接保留 id 最小的行）
- Gender 从 F/M 改成 Female/Male，Marital_Status 从 0/1 改成 No/Yes

## 分析结果

- 女性贡献了 70% 的销售额，是绝对主力
- 26-35 岁年龄段贡献最多，占 40%
- 未婚女性买得最多，占总销售额 41%
- 消费最高的职业是 IT、医疗、航空
- 北方邦、马哈拉施特拉邦、卡纳塔克邦是销售额前三的地区
- 中部和南部两个区域加起来占了 64%
- 卖得最好的品类是食品（32%）、服装、鞋类、电子产品

总结下来核心客户就是：26-35 岁、未婚、从事 IT/医疗/航空行业、来自中部或南部的女性，主要买食品和服装。

## Dashboard

Excel 里做了 9 个透视表和 8 张图，加了 Gender、Age Group、Zone 三个切片器，通过报表连接联动所有图表。顶部有三个 KPI 卡片显示总销售额、总订单数和平均年龄。

Power BI 版本做了三个页面：销售概览、客户分析、品类分析，配色用的蓝橙系。

## 文件结构

```
├── data/                  原始数据和清洗后数据
├── sql/                   清洗脚本和分析查询
├── python/                EDA notebook
├── excel/                 Excel Dashboard
├── powerbi/               Power BI 看板
└── images/                Dashboard 截图
```

## 怎么跑

SQL：先建 diwali 库，用 DataGrip 导入 raw_diwali_sales.csv（编码选 windows-1252），然后依次跑 01_data_cleaning.sql 和 02_analysis_queries.sql。

Python：pip install pandas matplotlib seaborn，然后用 Jupyter 打开 notebook。

Excel：直接打开 Diwali_Sales_Dashboard.xlsx，切到 dashboard 工作表点切片器就能筛选。
