-- Calculate the Radius of Influence combined with Trendsetter Score 
WITH TrendsetterCheckins AS (
    SELECT
        uc.USER_ID AS trendsetter_user_id,
        uc.LOCATION_ID,
        uc.CHECKIN_DATETIME
    FROM
        CARPE_DATA.TRENDSETTER.USER_CHECKIN uc
),
TrendsetterPairs AS (
    SELECT
        ts1.trendsetter_user_id AS trendsetter_id,
        ts2.USER_ID AS compared_user_id,
        ts1.LOCATION_ID,
        ts1.CHECKIN_DATETIME AS trendsetter_checkin_datetime,
        ts2.CHECKIN_DATETIME AS compared_checkin_datetime,
        uf.FRIEND_ID,
        CASE
            WHEN uf.FRIEND_ID IS NOT NULL THEN 1
            ELSE 0
        END AS has_friend
    FROM
        TrendsetterCheckins ts1
        JOIN CARPE_DATA.TRENDSETTER.USER_CHECKIN ts2 ON ts1.LOCATION_ID = ts2.LOCATION_ID
        AND ts1.CHECKIN_DATETIME < ts2.CHECKIN_DATETIME
        AND ts1.trendsetter_user_id != ts2.USER_ID
        LEFT JOIN CARPE_DATA.TRENDSETTER.USER_FRIENDSHIP uf ON ts1.trendsetter_user_id = uf.USER_ID
                                                            AND ts2.USER_ID = uf.FRIEND_ID
),
TrendsetterScores AS (
    SELECT
        tp.trendsetter_id,
        COUNT(DISTINCT tp.compared_user_id) AS num_people_visited,
        COUNT(DISTINCT tp.LOCATION_ID) AS num_distinct_locations
    FROM
        TrendsetterPairs tp
    WHERE
        tp.has_friend = 1
    GROUP BY
        tp.trendsetter_id
),
TrendsetterScoresFinal AS (
SELECT
    ts.trendsetter_id,
    ts.num_people_visited + ts.num_distinct_locations AS trendsetter_score
FROM
    TrendsetterScores ts
ORDER BY
    trendsetter_score DESC
),
RadiusOfInfluence AS (
    SELECT
        USER_ID,
        POWER(MAX(LATITUDE) - MIN(LATITUDE), 2) + POWER(MAX(LONGITUDE) - MIN(LONGITUDE), 2) AS radius_squared
    FROM
        CARPE_DATA.TRENDSETTER.USER_CHECKIN
    GROUP BY USER_ID
)
SELECT
    ri.user_id as trendsetter_id,
    CASE
        WHEN tsf.trendsetter_score is null then 0
        ELSE tsf.trendsetter_score
    END as trendsetter_score,
    SQRT(ri.radius_squared) AS radius_of_influence
FROM
    RadiusOfInfluence ri
    LEFT JOIN TrendsetterScoresFinal tsf ON tsf.trendsetter_id = ri.USER_ID
ORDER BY radius_of_influence DESC
LIMIT 10;
