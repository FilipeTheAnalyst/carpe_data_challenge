# Trendsetter Challenge

## Technologies Used
In order to complete this exercise I chose the following tecnhologies:
- **Snowflake:** Data Warehouse to store the data and create the tables accordingly to what was requested on the exercise
- **SQL:** Programming language used to define the scripts in order to meet the deliverables defined for this exercise

## Tables Definition
In order to hold the data from the dataset specified, I created the following tables:

**User_Friendship**
```
create or replace TABLE CARPE_DATA.TRENDSETTER.USER_FRIENDSHIP (
	USER_ID NUMBER(38,0),
	FRIEND_ID NUMBER(38,0)
);
```

**User_Checkin**
```
create or replace TABLE CARPE_DATA.TRENDSETTER.USER_CHECKIN (
	USER_ID NUMBER(38,0),
	CHECKIN_DATETIME TIMESTAMP_NTZ(9),
	LATITUDE NUMBER(38,0),
	LONGITUDE NUMBER(38,0),
	LOCATION_ID NUMBER(38,0)
);
```

To provide the answers to the exercise, the following tables were defined:

**Trendsetter_Score**
![image](https://github.com/FilipeTheAnalyst/carpe_data_challenge/assets/61323876/1807f613-5e1e-4958-9dcd-451e8b5dd362)

[SQL Script](/trendsetter_score.sql)

**Radius_Of_Influence**
![image](https://github.com/FilipeTheAnalyst/carpe_data_challenge/assets/61323876/769c8e2e-af58-40e2-9416-bd6a252383b0)

[SQL Script](/radius_of_influence.sql)

**Radius_Of_Influence_Trendsetter**
![image](https://github.com/FilipeTheAnalyst/carpe_data_challenge/assets/61323876/32c20187-729e-421c-a942-032c615778ce)

[SQL Script](/radius_of_influence_trendsetter_score_combined.sql)


