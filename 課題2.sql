/*
 * 7日間の集計をするために、店舗 x 商品の粒度で行数をカウントしている row_numを追加した
 * 課題1で作成したTableはDateに関して販売期間内なら欠損がないため行数でも問題ない
 * 対象期間は、2020-01-01 ~ 2020-12-31であり後ろ7日間の集計がほしいので6日間足した期間で抽出している
 */
WITH tmp AS (
    SELECT 
        sales_date,
        store_code,
        item_code,
        sales_quantity,
        ROW_NUMBER() OVER (PARTITION BY store_code, item_code ORDER BY sales_date DESC) AS row_num
    FROM date_store_item_salesquantity
    WHERE sales_date BETWEEN CAST('2020-01-01' AS DATE) AND DATE_ADD(DATE '2020-12-31',  INTERVAL 6 DAY)
    GROUP BY sales_date, store_code, item_code, sales_quantity
)

/*
 * 日 x 店舗 x 商品毎の後ろ7日間の売数を集計する
 * row_num >= 7の条件により以下条件を満たすようにしている
 * > - ただし、販売終了日の関係上7日に満たない日のレコードは出力から除外してください
 */
SELECT 
    sales_date,
    store_code,
    item_code,
    SUM(sales_quantity) OVER (PARTITION BY store_code, item_code ORDER BY sales_date DESC ROWS BETWEEN 6 PRECEDING AND 0 FOLLOWING)
FROM tmp
WHERE row_num >= 7