USE bos_ddmban_sql_analysis;

-- FILTERING DATA AS A HYPOTHESIS TEST FOR THE BUSINESS QUESTION. 

-- EXTRACTING AVERAGE PRICE AND STANDARD DEVIATION OF PRICE FOR PRODUCTS
-- WITH AND WITHOUT BADGES.
SELECT 	ROUND(AVG(   regular_price),2) 	AS avg_regular_price, 
		ROUND(STDDEV(regular_price),2) 	AS stddev_of_regular_price, 
        COUNT( 		 product_name) 		AS number_of_observations,
		CASE 
			WHEN sum_badges > 0 THEN 'yes'
			WHEN sum_badges = 0 THEN 'no'
		END 					AS has_badge
FROM bmbandd_data
WHERE wf_product_id NOT IN ( -- FILTERING OUT ID THAT ARE DUPLICATED 
							SELECT COUNT(wf_product_id)
							FROM 		 bmbandd_data
							GROUP BY     wf_product_id
							HAVING COUNT(wf_product_id) > 1
							)
GROUP BY has_badge
;


-- -----------------------------

-- EXTRACTING AVERAGE PRICE AND STANDARD DEVIATION OF PRICE FOR PRODUCTS
-- THAT ARE DIVIDED INTO NO BADGE, LOW BADGE AMOUNT (0<5), MEDIUM
-- BADGE AMOUNT (4<9) AND HIGH BADGE AMOUNT (8<16)
SELECT 	COUNT(		 product_name) 		AS number_of_products, 
		ROUND(AVG(	 sum_badges)   ,2)	AS avg_number_of_badges, 
		ROUND(AVG(	 regular_price),2)	AS avg_regular_price,
        ROUND(STDDEV(regular_price),2) 	AS stddev_of_regular_price,
		CASE
			WHEN sum_badges > 8 THEN 'high_badge_amount'
			WHEN sum_badges > 4 THEN 'medium_badge_amount'
			WHEN sum_badges > 0 THEN 'low_badge_amount'
								ELSE  'no_badge'
        END 							AS badges_amount
FROM bmbandd_data
WHERE wf_product_id NOT IN ( -- FILTERING OUT ID'S THAT ARE DUPLICATED 
							SELECT COUNT(wf_product_id)
							FROM 		 bmbandd_data
							GROUP BY	 wf_product_id
							HAVING COUNT(wf_product_id) > 1
							)
GROUP BY badges_amount
;


-- ------------------------------

-- FINDING THE QUARTILE BRAKING POINTS IN regular_price 
-- WHICH WILL BE USED IN THE FOLOWING QUERIES
SELECT 	
NTILE(4) OVER (ORDER BY regular_price) AS regular_price_bin,
						regular_price
FROM 					bmbandd_data
GROUP BY 				regular_price
;
/*
FIRST QUIRTILE starts at 0
THE SECOND QURTILE STARTS AT 4.29 
THE THIRD QURTILE STARTS AT 7.99
THE FOURTH QUARTILE STARTS AT 16.49
*/

-- -------------------------------


-- FILTERING DATA A HYPOTHESIS TEST FOR THE BUSINESS QUESTION
-- BUT ONLY LOOKING AT THE SECOND AND THIRD QUARTILE IN ORDER TO 
-- ONLY SEE PRODUCTS MORE SIMILAR IN PRICE. IN ORDER TO EXTRACT 
-- AVERAGE PRICE AND STANDARD DEVIATION OF PRICE FOR PRODUCTS
-- WITH AND WITHOUT BADGES.
SELECT 	ROUND(AVG( 	 regular_price),2) 	AS avg_regular_price, 
		ROUND(STDDEV(regular_price),2) 	AS stddev_of_regular_price, 
        COUNT(		 product_name) 		AS number_of_observations,
		CASE 
			WHEN sum_badges > 0 THEN 'yes'
			WHEN sum_badges = 0 THEN 'no'
		END 							AS has_badge
FROM bmbandd_data
WHERE wf_product_id NOT IN ( -- FILTERING OUT ID'S THAT ARE DUPLICATED 
							SELECT COUNT(wf_product_id)
							FROM  		 bmbandd_data
							GROUP BY 	 wf_product_id
							HAVING COUNT(wf_product_id) > 1
							)
	AND regular_price >= 4.29 
    AND regular_price < 16.99
GROUP BY has_badge
;

-- ----------------

-- GROUPING THE NUMBER OF BADGES INTO FOUR CATEGORIES AND FILTERING OUT PRODUCTS IN THE
-- ONLY LOOKING AT THE SECOND AND THIRD QUARTILE SO PRODUCTS ARE MORE SIMILAR.
-- EXTRACTING AVERAGE PRICE AND STANDARD DEVIATION OF PRICE FOR PRODUCTS
-- THAT ARE DIVIDED INTO NO BADGE, LOW BADGE AMOUNT (0<5), MEDIUM
-- BADGE AMOUNT (4<9) AND HIGH BADGE AMOUNT (8<16)
SELECT 	COUNT( 		 product_name) 		AS number_of_products, 
		ROUND(AVG(   sum_badges)   ,2) 	AS avg_number_of_badges, 
		ROUND(AVG(   regular_price),2)	AS avg_regular_price,
        ROUND(STDDEV(regular_price),2) 	AS stddev_of_regular_price,
		CASE
			WHEN sum_badges > 8 THEN 'high_badge_amount'
			WHEN sum_badges > 4 THEN 'medium_badge_amount'
			WHEN sum_badges > 0 THEN 'low_badge_amount'
								ELSE  'no_badge'
        END 							AS badges_amount
FROM bmbandd_data
WHERE wf_product_id NOT IN ( -- FILTERING OUT ID'S THAT ARE DUPLICATED 
							SELECT COUNT(wf_product_id)
							FROM 		 bmbandd_data
							GROUP BY 	 wf_product_id
							HAVING COUNT(wf_product_id) > 1
							)
		AND regular_price >= 4.29 
        AND regular_price < 16.99
GROUP BY badges_amount
;
-- INSIGHT: 
/*
THE QUERY SHOWS THAT THE PRODUCTS WITHIN THE SECOND AND THIRD QUARTILE WITH NO
BADGES TREND TOWARDS HIGHER PRICES BY AROUND $1. FOR PRODUCTS WITH BADGES THE 
THE NUMBER OF BADGES DOES NOT SEEM TO HAVE ANY MAJOR IMPACT ON PRICE.
*/







-- HERE STARTS QUERIES FOR INSIGHTS







-- FINDING THE AVERAGE OF regular_price FOR ALL PRODUCTS
-- FOR THE NEXT QUERY
SELECT AVG(regular_price)
FROM 	   bmbandd_data
-- AVERAGE OF regular_price 7.69
;

-- GROUPING SUM BADGES INTO FOUR CATEGORIES. WITH THE AIM TO SEE IF CATEGORIES HAVE DIFFERENT AVERAGE PRICES. 
-- FOR ALL PRODUCTS WITH A regular_price LARGER THEN THE AVERAGE regular_price. 
SELECT 	COUNT(    product_name) 		AS number_of_products, 
		ROUND(AVG(sum_badges),	 2)		AS avg_number_of_badges, 
		ROUND(AVG(regular_price),2) 	AS avg_regular_price,
		CASE
			WHEN sum_badges > 8 THEN 'menny_badge_amount'
			WHEN sum_badges > 4 THEN 'medium_badge_amount'
			WHEN sum_badges > 0 THEN 'low_badge_amount'
								ELSE 'no_badge'
        END 				AS badges_amount
FROM bmbandd_data
WHERE regular_price IN	( -- SUBQUERY IS FILTERING FOR ALL PRODUCTS WITH A regular_price LARGER THEN THE AVERAGE regular_price.
                         SELECT 	regular_price
						 FROM 		bmbandd_data
						 GROUP BY 	regular_price
						 HAVING AVG(regular_price) > 7.69
                        )
GROUP BY badges_amount
;
-- INSIGHT:
/*
IT SEMS THAT medium_badge_amount HAS THE LARGEST IMPACT ON regular_price.
WHILE THERE IS NO REAL PRICE DIFFERENCE BETWEEN THE OTHER BADGE AMOUNTS
*/



-- 				FOLLOWING QUERY IS USED IN THE FIRST INSIGHT

-- GROUPING SUM BADGES INTO FOUR CATEGORIES. WITH THE AIM TO SEE IF CATEGORIES HAVE DIFFERENT AVERAGE PRICES.
-- FOR ALL PRODUCTS WITH A regular_price EQUAL OR SMALLER THEN THE AVERAGE regular_price. 
	SELECT	COUNT(       product_name) 		AS number_of_products, 
			ROUND(AVG(   sum_badges),	2) 	AS avg_number_of_badges, 
            ROUND(AVG(   regular_price),2)	AS avg_regular_price,
            ROUND(STDDEV(regular_price),2) 	AS stddev_of_regular_price,
			CASE
				WHEN sum_badges > 8 THEN 'menny_badge_amount'
				WHEN sum_badges > 4 THEN 'medium_badge_amount'
				WHEN sum_badges > 0 THEN 'low_badge_amount'
									ELSE 'no_badge'
			END 				AS badges_amount
FROM bmbandd_data
WHERE regular_price IN 	( -- SUBQUERY IS FILTERING FOR ALL PRODUCTS WITH A regular_price EQUAL TO OR SMALLER THEN THEN THE AVERAGE regular_price.
						 SELECT 	regular_price
						 FROM 	 	bmbandd_data
						 GROUP BY 	regular_price
						 HAVING AVG	(regular_price) <= 7.69
						 )
GROUP BY badges_amount
;
-- INSIGHT:
/*
IT SEMS THAT no_badge HAS THE LARGEST NEGATIVE IMPACT ON regular_price FOR PRODUCTS 
BELOVE THE AVERAGE PRICE OF 7.69. WHILE PRICES SEEM TO DECREASE THE MORE BADGES ARE ADDED
*/


-- 				FOLLOWING QUERY IS USED IN THE SECOND INSIGHT



/*
DIVIDING ALL PRODUCTS INTO THREE CAMPS. ON CAMP IS FOR BADGES THAT CAN ONLY BE PUT ON 
PRODUCTS IF THEY MEET SPECIFIC REQUIREMENTS. THE SECOND CAMP IS A FOR BADGES THAT 
DOSE NOT NEED TO MEET ANY REQUIREMENTS BY LAW IN ORDER TO BE PUT ON PRODUCTS. THE
THE THIRD CAMP REPRESENTS PRODUCTS WITHOUT BADGES. THE QUERY AIMS TO EXPLORE OF THERE IS 
A PRICE DIFFERENCE BETWEEN THE TWO TYPES OF BADGES.
*/
SELECT
CASE 
WHEN badge = 'vegan' 			 THEN 'no_badge_requierment'
WHEN badge = 'keto' 			 THEN 'no_badge_requierment'
WHEN badge = 'paleo' 			 THEN 'no_badge_requierment'
WHEN badge = 'vegetarian' 		 THEN 'no_badge_requierment'
WHEN badge = 'kosher'			 THEN 'no_badge_requierment'
WHEN badge = 'engine_2'			 THEN 'no_badge_requierment'
WHEN badge = 'whole_foods_diet'  THEN 'no_badge_requierment'
WHEN badge = 'gluten_free' 		 THEN 'badge_requierment'
WHEN badge = 'sugar_conscious' 	 THEN 'badge_requierment'
WHEN badge = 'dairy_free' 		 THEN 'badge_requierment'
WHEN badge = 'high_fiber' 		 THEN 'badge_requierment'
WHEN badge = 'low_sodium' 		 THEN 'badge_requierment'
WHEN badge = 'low_fat' 			 THEN 'badge_requierment'
WHEN badge = 'wheat_free' 		 THEN 'badge_requierment'
WHEN badge = 'organic' 			 THEN 'badge_requierment'
WHEN badge = 'no_badge'			 THEN 'no_badge'
END 							 AS badge_constraint, 
ROUND(AVG(avg_regular_price_per_badge),2) AS avg_price_per_camp -- READ NOT BEFORE QUERY TO UNDERSTAN CAMP
FROM bmbandd_data AS mban1, ( -- CREATING A TABLE WITH A COLUME FOR ALL BADGES AND NO BADGE
							 SELECT 
							 CASE
							 WHEN is_vegan 	 = 1 THEN 'vegan'
                             WHEN sum_badges = 0 THEN 'no_badge'
												 ELSE 'other'
							 END 				 AS badge, 
                             AVG(regular_price)  AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_vegan = 1
                             OR sum_badges 	= 0
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_keto_friendly = 1 	THEN 'keto'
														ELSE 'other'
							 END 						AS badge, 
                             AVG(regular_price) 		AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_keto_friendly = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_paleo_friendly = 1 THEN 'paleo'
														ELSE 'other'
							 END 						AS badge, 
                             AVG(regular_price) 		AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_paleo_friendly = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_vegetarian = 1 	THEN 'vegetarian'
														ELSE 'other'
							 END 						AS badge, 
                             AVG(regular_price)    		AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_vegetarian = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_kosher = 1 		THEN 'kosher'
														ELSE 'other'
							 END 						AS badge, 
							 AVG(regular_price) 		AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_kosher = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_engine_2 = 1 		THEN 'engine_2'
														ELSE 'other'
							 END 						AS badge, 
                             AVG(regular_price) 		AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_engine_2 = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_whole_foods_diet = 1 	THEN 'whole_foods_diet'
															ELSE 'other'
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_whole_foods_diet = 1
							 GROUP BY badge

-- --------
UNION

							 SELECT 
							 CASE
							 WHEN is_gluten_free = 1 		THEN 'gluten_free'
															ELSE 'other'	
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_gluten_free = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_sugar_conscious = 1 	THEN 'sugar_conscious'
															ELSE 'other'
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_sugar_conscious = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_dairy_free = 1 		THEN 'dairy_free'
															ELSE 'other'	
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_dairy_free = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_high_fiber = 1 		THEN 'high_fiber'
															ELSE 'other'
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_high_fiber = 1
							 GROUP BY badge

UNION

							 SELECT	 
							 CASE
							 WHEN is_low_sodium = 1 		THEN 'low_sodium'
															ELSE 'other'
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_low_sodium = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE	
							 WHEN is_low_fat = 1 			THEN 'low_fat'
															ELSE 'other'
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_low_fat = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_wheat_free = 1 		THEN 'wheat_free'
															ELSE 'other'
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_wheat_free = 1
							 GROUP BY badge

UNION

							 SELECT 
							 CASE
							 WHEN is_organic = 1 			THEN 'organic'
															ELSE 'other'
							 END 							AS badge, 
                             AVG(regular_price) 			AS avg_regular_price_per_badge
							 FROM bmbandd_data
							 WHERE is_organic = 1
							 GROUP BY badge) 				AS badge_table
GROUP BY badge_constraint
;
/*
INSIGHT:
THE BADGES THAT DOES NOT NEED TO MEET ANY REGULATORY REQUIREMENTS SEEM TO BE PRICED HIGHER 
THEN PRODUCTS WITHOUT A BADGE AND PRODUCTS WITH BADGES THAT HAVE REGULATORY REQUIREMENTS.
PRODUCTS WITH NO BADGE ALSO SEEM TO BE PRICED HIGHER THAN PRODUCTS WITH BADGES THAT HAVE
REGULATORY REQUIREMENTS.
*/




