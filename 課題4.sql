/*
 * 一時的に、商品単価履歴テーブルに格納されている単価を在庫テーブルにLEFT JOINして更新日のみに単価を格納した
 * 在庫テーブルは毎日集計されているため標品単価履歴テーブルにある単価のJOIN漏れはない
 */
WITH tmp AS (
SELECT 
    stock.sales_date,
    stock.store_code,
    stock.item_code,
    stock.stock_quantity,
    mip.unit_price          -- 課題ではitem_nameとなっていましたがunit_priceにリネームしています
FROM date_store_item_stockquantity stock
LEFT JOIN m_item_price mip  -- 課題ではm_itemとなっていましたがm_item_priceにリネームしています
ON stock.item_code = mip.item_code
AND
stock.sales_date = mip.price_set_date
WHERE sales_date BETWEEN CAST('2020-01-01' AS DATE) AND BETWEEN CAST('2020-12-31' AS DATE)
)

/*
 * tmpTableには、単価がnullの箇所が存在する
 * そのため、nullの箇所は前日の単価を格納するように変更している
 * (実際はsales_dateを昇順で並び替えた一行前の単価を格納している)
 * 例のごとくDateに関しては毎日更新されているので問題ない
 */
SELECT 
    sales_date,
    store_code,
    item_code,
    stock_quantity,
    COALESCE(unit_price, LAG(unit_price, 1) OVER (PARTITION BY store_code, item_code ORDER BY sales_date)) AS unit_price
FROM tmp