CREATE OR REPLACE TABLE "DATABASE_NAME"."SCHEMA_NAME"."TABLE_NAME" AS(
WITH SEARCHERS AS (
    SELECT
      CONCAT( "records":fullVisitorId::VARCHAR(16777216), '_', "records":visitId::VARCHAR(16777216) ) AS "SESSION_ID",
      ANY_VALUE( TO_DATE( "records":date::VARCHAR(16777216), 'YYYYMMDD' ) ) AS DATE,
      IFF( SUM( CASE WHEN (CONTAINS( h.value:page.pagePath::VARCHAR(16777216), '/search/' )  AND h.value:isInteraction::VARCHAR(16777216) = TRUE ) THEN 1
      ELSE 0
      END 
      ) >= 1, 1, 0) AS IS_SEARCHER
    FROM 
      DATABASE_NAME.SCHEMA_NAME.TABLE_NAME ga, LATERAL FLATTEN("records":hits) h
    WHERE TO_DATE( "records":date::VARCHAR(16777216), 'YYYYMMDD' ) >= '2019-01-01'
    GROUP BY 1
),
SESSIONS AS (
    SELECT
      CONCAT( "records":fullVisitorId::VARCHAR(16777216), '_', "records":visitId::VARCHAR(16777216) ) AS "SESSION_ID",
      ANY_VALUE( "records":clientId::VARCHAR(16777216) ) AS CLIENT_ID,
      ANY_VALUE( "records":fullVisitorId::VARCHAR(16777216) ) AS FULL_VISITOR_ID,
      ANY_VALUE( 
        IFNULL( "records":userId::VARCHAR(16777216) , '(not set)' )
      ) AS USER_ID,
      ANY_VALUE( "records":visitId::VARCHAR(16777216) ) AS VISIT_ID,
      ANY_VALUE( TO_DATE( "records":date::VARCHAR(16777216), 'YYYYMMDD' ) ) AS DATE,
      ANY_VALUE( "records":device.language::VARCHAR(16777216) ) AS LANGUAGE,
      ANY_VALUE( "records":geoNetwork.country::VARCHAR(16777216) ) AS COUNTRY,
      ANY_VALUE( "records":device.deviceCategory::VARCHAR(16777216) ) AS DEVICE,
      ANY_VALUE( "records":totals.visits::VARCHAR(16777216) ) AS SITE_VISIT,
      ANY_VALUE( 
        ZEROIFNULL( ROUND ( "records":totals.totalTransactionRevenue::NUMBER(38,0) / 1000000 , 2 ) )
      ) AS SITE_TRANSACTION_REVENUE,
      ANY_VALUE( "records":totals.transactions::VARCHAR(16777216) ) AS SITE_TRANSACTION,
      ANY_VALUE( IFF("records":totals.transactions::VARCHAR(16777216) > 0, 1, 0) ) AS IS_TRANSACTION_IN_SESSION,
      ANY_VALUE( "records":trafficSource.source::VARCHAR(16777216) ) AS SOURCE,
      ANY_VALUE( "records":trafficSource.medium::VARCHAR(16777216) ) AS MEDIUM,
      ANY_VALUE( "records":trafficSource.campaign::VARCHAR(16777216) ) AS CAMPAIGN,
      ANY_VALUE( "records":trafficSource.keyword::VARCHAR(16777216) ) AS KEYWORD,
      ANY_VALUE( "records":visitNumber::VARCHAR(16777216) ) AS VISIT_NUMBER,
      ZEROIFNULL( ANY_VALUE( "records":totals.newVisits::VARCHAR(16777216) ) ) AS NEW_VISITS
    FROM 
      DATABASE_NAME.SCHEMA_NAME.TABLE_NAME ga
    WHERE TO_DATE( "records":date::VARCHAR(16777216), 'YYYYMMDD' ) >= '2019-01-01'
    GROUP BY 1
)
SELECT S.*, 'BRAND_NAME' AS BRAND, SR.IS_SEARCHER FROM SESSIONS S 
LEFT JOIN SEARCHERS SR ON SR.SESSION_ID = S.SESSION_ID
)
