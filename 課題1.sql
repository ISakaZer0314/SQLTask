/*
 * 集計対象期間が一日づつ格納されたDateTableを作成した
 */
WITH date_table AS (
    SELECT
        sales_date
    FROM
        UNNEST(
            GENERATE_DATE_ARRAY(
                '2020-01-01',
                '2021-01-31',
                INTERVAL 1 DAY)
        ) AS sales_date
),

/*
 * 作成したDateTableに各商品の販売期間内の日付データが格納されているTableを作成した
 * 日付データ(販売期間) x 商品 のデータができる
 * 商品マスタの販売終了日がnullの場合は集計対象期間の最終日で補完しいる
 */
date_item AS (
    SELECT 
        date_table.sales_date,
        mi.item_code
    FROM date_table
    CROSS JOIN m_item mi
    WHERE date_table.sales_date BETWEEN mi.sales_start_date AND COALESCE(mi.sales_end_date, CAST('2021-01-31' AS DATE))
),

/*
 * 各商品の販売期間内のデータに対して、店舗数分格納するためのTableを作成する
 * 日付データ(販売期間) x 商品 x 店舗 のデータができる
 */
date_store_item AS (
    SELECT 
        date_item.sales_date,
        ms.store_code,
        date_item.item_code
    FROM date_item 
    CROSS JOIN m_store ms
),

/*
 * 売上Tableは日時別で格納されているので、日別に集計し直す
 */
aggregate_sales AS (
  SELECT
    DATE(sales_datetime) AS sales_date,
    store_code,
    item_code,
    SUM(sales_quantity) AS sum_sales_quantity
  FROM t_sales
  GROUP BY DATE(sales_datetime), store_code, item_code
)

/*
 * 販売期間中の毎日のデータを作成する
 * COALESCEを使用して販売実績がない日に関しては0が入るようにしている
 */
SELECT 
    dsi.sales_date,
    dsi.store_code,
    dsi.item_code,
    COALESCE(agn.sum_sales_quantity, 0) AS sales_quantity
FROM date_store_item dsi
LEFT JOIN aggregate_sales agn
ON dsi.sales_date = agn.dsales_datet
AND
dsi.store_code = agn.store_code
AND
dsi.item_code = agn.item_code