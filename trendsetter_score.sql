WITH TrendsetterCheckins AS (
-- This CTE retrieves all the user_ids with their respective location_id and checkin_datetime
-- The user_ids will be considered as potential trendsetter_user_id to compare with other user_ids
    SELECT
        uc.USER_ID AS trendsetter_user_id,
        uc.LOCATION_ID,
        uc.CHECKIN_DATETIME
    FROM
        CARPE_DATA.TRENDSETTER.USER_CHECKIN uc
),
TrendsetterPairs AS (
-- This CTE creates a join between the previous CTE (TrendsetterCheckins) and User_Checkin to compare the TrendSetter with the other user_ids
-- that went to the same location_id after the trendsetter (> checkin_datetime)
-- Additionally joined also with the user_friendship table to identify if the trendsetter is a friend of the person that has visited the location afterwards
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
-- Using the previous 2 CTEs as the foundation, the trendsetter score is calculated by adding the number of distinct locations and people
-- that have visited a location after the "trendsetter" (and retrieve the top 10)
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
)
SELECT
    ts.trendsetter_id,
    ts.num_people_visited + ts.num_distinct_locations AS trendsetter_score,
    DENSE_RANK() OVER(ORDER BY ts.num_people_visited + ts.num_distinct_locations DESC) as trendsetter_score_rank
FROM
    TrendsetterScores ts
QUALIFY DENSE_RANK() OVER(ORDER BY ts.num_people_visited + ts.num_distinct_locations DESC) <= 10
ORDER BY
    trendsetter_score DESC
;
