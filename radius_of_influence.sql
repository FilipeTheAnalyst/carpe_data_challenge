-- Calculate the Radius of Influence
WITH RadiusOfInfluence AS (
    SELECT
        USER_ID,
        POWER(MAX(LATITUDE) - MIN(LATITUDE), 2) + POWER(MAX(LONGITUDE) - MIN(LONGITUDE), 2) AS radius_squared
    FROM
        CARPE_DATA.TRENDSETTER.USER_CHECKIN
    GROUP BY USER_ID
)
SELECT
    ri.user_id as trendsetter_id,
    ROUND(SQRT(ri.radius_squared),2) AS radius_of_influence
FROM RadiusOfInfluence ri
ORDER BY radius_of_influence DESC
LIMIT 10;
