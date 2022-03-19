/*
 * 日 x 店舗 x 商品毎に統計量を算出している
 * 課題2と同様販売期間内はDateに関して販売期間内なら欠損がないため行数でも問題ない
 * LAG関数でsales_dateで並べられたsales_quantityのN行前(つまりN日前)でデータを取得している
 */
SELECT 
    sales_date,
    store_code,
    item_code,
    sales_quantity,
    LAG(sales_quantity, 1) OVER (PARTITION BY store_code, item_code ORDER BY sales_date ASC) AS sales_quantity_lag1,
    LAG(sales_quantity, 7) OVER (PARTITION BY store_code, item_code ORDER BY sales_date ASC) AS sales_quantity_lag7,
    MIN(sales_quantity)    OVER (PARTITION BY store_code, item_code ORDER BY sales_date ASC ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS sales_quantity_agg7_min,
    MAX(sales_quantity)    OVER (PARTITION BY store_code, item_code ORDER BY sales_date ASC ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS sales_quantity_agg7_max,
    AVG(sales_quantity)    OVER (PARTITION BY store_code, item_code ORDER BY sales_date ASC ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS sales_quantity_agg7_avg,
    STDDEV(sales_quantity) OVER (PARTITION BY store_code, item_code ORDER BY sales_date ASC ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING) AS sales_quantity_agg7_stddev
FROM date_store_item_salesquantity
WHERE sales_date BETWEEN CAST('2020-01-01' AS DATE) AND BETWEEN CAST('2020-12-31' AS DATE)
GROUP BY sales_date, store_code, item_code, sales_quantity
