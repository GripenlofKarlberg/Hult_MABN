/*
Project intro:

In the H_Accounting Assignment data regarding a fictional company was provided. 
The Schema provided contained 23 tables. The tables contained information regarding
the company’s different accounts, report order, journal entries company addresses,
and much more. However, most tables were identified as noise for the assignment.
The only tables used were the journal entry line item, account, journal entry,
and statement section.

The Aim of the assignment was to create profit and loss as well as balance sheet
statements for the company and insert the results into temporary tables (tmp) tables
through a stored procedure. When creating the stored procedure a user input was also
created. The user input allows the user to insert a year present in the dataset and 
the tmp table would be created based on that year.
*/

/*
Business Analysis with Structured Data
A2: H_Accounting [Pairs/Trios]
Aouthers: Axel Gripenlöf Karlberg, Adrian Lopez Perales, Megan Bierfert
*/

USE h_accounting;

-- DROPING PROCEDURE IF IT EXISTS IN ORDER TO REPLACE ANY CURRENT PROCEDURE WITH THE SAME NAME
DROP PROCEDURE IF EXISTS akarlberg_INCOME_BALANCE_STATMENTS;

DELIMITER $$
-- ASSIGNING THE PROCEDURE NAME AND CREATING THE CONDITION 
CREATE PROCEDURE h_accounting.akarlberg_INCOME_BALANCE_STATMENTS(varYear SMALLINT)
BEGIN

-- DECLARING all the P/L statement VARIABLES WE WANT IN THE TABLE
DECLARE varTotalRevenues 		  					DOUBLE DEFAULT 0; -- Total Revenues 
DECLARE varTotalRevenues_previous 					DOUBLE DEFAULT 0; -- Total Revenues year prior
DECLARE varRRD 					  					DOUBLE DEFAULT 0; -- Returns, Refunds, Disconts
DECLARE varRRD_previous 		  					DOUBLE DEFAULT 0; -- Returns, Refunds, Disconts year prior
DECLARE varCOGS 			  	  					DOUBLE DEFAULT 0; -- Cost of Goods and Services
DECLARE varCOGS_previous 		  					DOUBLE DEFAULT 0; -- Cost of Goods and Services year prior
DECLARE varAdminExp				  					DOUBLE DEFAULT 0; -- Administrative Expenses
DECLARE varAdminExp_previous 	 					DOUBLE DEFAULT 0; -- Administrative Expenses year prior
DECLARE varSellingExp 			  					DOUBLE DEFAULT 0; -- Selling Expenses
DECLARE varSellingExp_previous 	  					DOUBLE DEFAULT 0; -- Selling Expenses year prior
DECLARE varOtherExp   	 		  					DOUBLE DEFAULT 0; -- Other Expenses 
DECLARE varOtherExp_previous 	  					DOUBLE DEFAULT 0; -- Other Expenses year prior
DECLARE varOtherIncome 								DOUBLE DEFAULT 0; -- Other Income 
DECLARE varOtherIncome_previous  					DOUBLE DEFAULT 0; -- Other Income year prior
DECLARE varIncomeTax			  					DOUBLE DEFAULT 0; -- Income Tax
DECLARE varIncomeTax_previous	  					DOUBLE DEFAULT 0; -- Income Tax year prior
DECLARE varOtherTax 	 		  					DOUBLE DEFAULT 0; -- Other Tax 
DECLARE varOtherTax_previous 	  					DOUBLE DEFAULT 0; -- Other Tax year prior

-- We declare all the B&S variables so we can insert values into them. 
DECLARE varCurrentAssets 							DOUBLE DEFAULT 0 ;
DECLARE varCurrentAssetsPrevious 					DOUBLE DEFAULT 0 ;
DECLARE varFixedAssets 								DOUBLE DEFAULT 0 ;
DECLARE varFixedAssetsPrevious 						DOUBLE DEFAULT 0 ;
DECLARE varDeferredAssets 							DOUBLE DEFAULT 0 ;
DECLARE varDeferredAssetsPrevious 					DOUBLE DEFAULT 0 ;
DECLARE varCurrentLiab 								DOUBLE DEFAULT 0 ;
DECLARE varCurrentLiabPrevious 						DOUBLE DEFAULT 0 ;
DECLARE varLongTermLiab 							DOUBLE DEFAULT 0 ;
DECLARE varLongTermLiabPrevious 					DOUBLE DEFAULT 0 ;
DECLARE varDeferredLiab 							DOUBLE DEFAULT 0 ;
DECLARE varDeferredLiabPrevious 					DOUBLE DEFAULT 0 ;
DECLARE varEquity 									DOUBLE DEFAULT 0 ;
DECLARE varEquityPrevious 							DOUBLE DEFAULT 0 ;
DECLARE varTotalAsset 								DOUBLE DEFAULT 0 ;
DECLARE varTotalAssetPrevious 						DOUBLE DEFAULT 0 ;
DECLARE varTotalLiabilities 						DOUBLE DEFAULT 0 ;
DECLARE varTotalLiabilitiesPrevious 				DOUBLE DEFAULT 0 ;
DECLARE varEquityaLiabilities 						DOUBLE DEFAULT 0 ;
DECLARE varEquityaLiabilitiesPrevious				DOUBLE DEFAULT 0 ;


-- ASSIGNING THE VALUE FOR TOTAL REVENUE VARIABLE 
SELECT SUM(credit) INTO varTotalRevenues
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section      = 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code      = 'REV'			-- FILTERING FOR REVENUE
		AND YEAR(entry_date) 		        = varYear		-- FILTERING FOR varYear
;

-- ASSIGNING THE VALUE FOR TOTAL REVENUE FROM THE YEAR PREVIOUS VARIABLE
SELECT SUM(credit) INTO varTotalRevenues_previous
    FROM journal_entry_line_item            AS jeli
    INNER JOIN `account`                    AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry                AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section            AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section      = 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code      = 'REV'			-- FILTERING FOR REVENUE
		AND YEAR(entry_date) 		        = varYear - 1 	-- FILTERING FOR varYear - 1
     ;
 
-- ASSIGNING THE VALUE FOR PREVIOUS  VARIABLE 
SELECT SUM(credit) INTO varRRD
    FROM journal_entry_line_item            AS jeli
    INNER JOIN `account`                    AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry                AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section            AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section      = 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code      = 'RET'			-- FILTERING FOR Returns, Refunds, Disconts
		AND YEAR(entry_date) 		        = varYear 		-- FILTERING FOR varYear 
;

-- ASSIGNING THE VALUE FOR RETURNS FOR PREVIOUS  YEAR VARIABLE
SELECT SUM(credit) INTO varRRD_previous
    FROM journal_entry_line_item            AS jeli
    INNER JOIN `account`                    AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry                AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section            AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section      = 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code      = 'RET'			-- FILTERING FOR Returns, Refunds, Disconts
		AND YEAR(entry_date) 		        = varYear - 1 	-- FILTERING FOR varYear - 1
;

-- ASSIGNING THE VALUE FOR COGS VARIABLE
SELECT SUM(credit) INTO varCOGS
    FROM journal_entry_line_item            AS jeli
    INNER JOIN `account`                    AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry                AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section            AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section      = 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code      = 'COGS'		-- FILTERING FOR COGS
		AND YEAR(entry_date) 		        = varYear		-- FILTERING FOR varYear 
;

-- ASSIGNING THE VALUE FOR COGS PREVIOUS YEAR VARIABLE
SELECT SUM(credit) INTO varCOGS_previous
    FROM journal_entry_line_item            AS jeli
    INNER JOIN `account`                    AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry                AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section            AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section      = 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'COGS'		-- FILTERING FOR COGS
		AND YEAR(entry_date) 		    	= varYear - 1	-- FILTERING FOR varYear - 1
     ;
     
-- ASSIGNING  THE VALUE FOR ADMIN EXPENSES
SELECT SUM(credit) INTO varAdminExp
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'GEXP'		-- FILTERING FOR ADMIN EXPENSES
		AND YEAR(entry_date) 		    	= varYear		-- FILTERING FOR varYear 
;

-- DECLARING THE VALUE FOR ADMIN EXPENSES PREVIOUS YEAR
SELECT SUM(credit) INTO varAdminExp_previous
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'GEXP'		-- FILTERING FOR ADMIN EXPENSES
		AND YEAR(entry_date) 		    	= varYear - 1	-- FILTERING FOR varYear - 1
;
-- DECLARING THE VALUE FOR SELLING EXPENSES
SELECT SUM(credit) INTO varSellingExp
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'SEXP'		-- FILTERING FOR SELLEING EXPENSES
		AND YEAR(entry_date) 		    	= varYear 		-- FILTERING FOR varYear 
;

-- DECLARING THE VALUE FOR SELLING EXPENSES PREVIOUS YEAR
SELECT SUM(credit) INTO varSellingExp_previous
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'SEXP'		-- FILTERING FOR SELLEING EXPENSES
		AND YEAR(entry_date) 		    	= varYear - 1	-- FILTERING FOR varYear - 1
;
     
     -- DECLARING THE VALUE FOR OTHER EXPENSES
SELECT SUM(credit) INTO varOtherExp 
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'OEXP'		-- FILTERING FOR OTHER EXPENSES
		AND YEAR(entry_date) 		    	= varYear 		-- FILTERING FOR varYear 
;
    
     
-- DECLARING THE VALUE FOR OTHER EXPENSES PREVIOUS YEAR
SELECT SUM(credit) INTO varOtherExp_previous
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'OEXP'		-- FILTERING FOR OTHER EXPENSES
		AND YEAR(entry_date) 		    	= varYear - 1	-- FILTERING FOR varYear - 1
;
     
     -- DECLARING THE VALUE FOR OTHER INCOME
SELECT SUM(credit) INTO varOtherIncome
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'OI'			-- FILTERING FOR OTHER INCOME
		AND YEAR(entry_date) 		    	= varYear		-- FILTERING FOR varYear 
;

-- DECLARING THE VALUE FOR OTHER INCOME FOR PREVIOUS YEAR
SELECT SUM(credit) INTO varOtherIncome_previous
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'OI'			-- FILTERING FOR OTHER INCOME
		AND YEAR(entry_date) 		    	= varYear - 1	-- FILTERING FOR varYear - 1
;

-- DECLARING THE VALUE FOR INCOEME TAX
SELECT SUM(credit) INTO varIncomeTax
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'INCTAX'		-- FILTERING FOR INCOEME TAX
		AND YEAR(entry_date) 		    	= varYear 		-- FILTERING FOR varYear 
;

-- DECLARING THE VALUE FOR INCOME TAX FOR PREVIOUS YEAR
SELECT SUM(credit) INTO varIncomeTax_previous 
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'INCTAX'		-- FILTERING FOR INCOEME TAX
		AND YEAR(entry_date) 		    	= varYear - 1	-- FILTERING FOR varYear - 1
;


-- DECLARING THE VALUE FOR OTHER TAX
SELECT SUM(credit) INTO varOtherTax
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section  	= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code  	= 'OTHTAX'		-- FILTERING FOR OTHER TAX
		AND YEAR(entry_date) 		    	= varYear		-- FILTERING FOR varYear 
;

-- DECLARING THE VALUE FOR OTHER TAX FOR PREVIOUS YEAR
SELECT SUM(credit) INTO varOtherTax_previous 
    FROM journal_entry_line_item 			AS jeli
    INNER JOIN `account` 					AS a ON a.account_id = jeli.account_id
    INNER JOIN journal_entry 				AS je ON jeli.journal_entry_id = je.journal_entry_id
	INNER JOIN statement_section 			AS sts ON a.profit_loss_section_id = sts.statement_section_id
	WHERE sts.is_balance_sheet_section 		= 0				-- EXTRACTING ROWS THAT BELONG TO THE P&L STATMENT
		AND sts.statement_section_code 		= 'OTHTAX'		-- FILTERING FOR OTHER TAX
		AND YEAR(entry_date) 		   		= varYear - 1	-- FILTERING FOR varYear - 1
;
    
    

-- Creating the values for the variables needed for B&S

 -- Code for calculating the CURRENT ASSETS: 

SELECT IFNULL(SUM(debit)-SUM(credit),0) 	INTO varCurrentAssets
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced      		= 1
	AND statement_section_code        		= 'CA'
	AND YEAR(je.entry_date)           		= varYear
;

SELECT (SUM(debit)-SUM(credit)) INTO varCurrentAssetsPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'CA'
	AND YEAR(je.entry_date) 				= varYear - 1 
;

-- Code for calculating the FIXED ASSETS: 

SELECT IFNULL(SUM(debit)-SUM(credit),0) 	INTO varFixedAssets
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'FA'
	AND YEAR(je.entry_date) 				= varYear
;

SELECT (SUM(debit)-SUM(credit)) INTO varFixedAssetsPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'FA'
	AND YEAR(je.entry_date) 				= varYear - 1
;

-- Code for calculating the DEFERRED ASSETS: 

SELECT IFNULL(SUM(debit)-SUM(credit),0) INTO varDeferredAssets
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'DA'
	AND YEAR(je.entry_date) 				= varYear
;

SELECT (SUM(debit)-SUM(credit)) INTO varDeferredAssetsPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry	 	AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'DA'
	AND YEAR(je.entry_date) 				= varYear - 1
;

--  Code for calculating the CURRENT LIABILITIES

SELECT IFNULL(SUM(debit) * -1 +SUM(credit),0) INTO varCurrentLiab
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'CL'
	AND YEAR(je.entry_date) 				= varYear
;

SELECT (SUM(debit) * -1 +SUM(credit)) INTO varCurrentLiabPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section   AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id           <> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code              = 'CL'
	AND YEAR(je.entry_date)      			= varYear - 1
;

--  Code for calculating the LONG TERM LIABILITIES

SELECT IFNULL(SUM(debit) * -1 +SUM(credit),0) INTO varLongTermLiab
FROM h_accounting.journal_entry_line_item AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'LLL'
	AND YEAR(je.entry_date) 				= varYear
;

SELECT (SUM(debit) * -1 +SUM(credit)) INTO varLongTermLiabPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'LLL'
	AND YEAR(je.entry_date) 				= varYear - 1
;

--  Code for calculating the DEFERRED LIABILITIES 

SELECT IFNULL(SUM(debit) * -1 +SUM(credit),0) INTO varDeferredLiab
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'DL'
	AND YEAR(je.entry_date) 				= varYear
;

SELECT (SUM(debit) * -1 +SUM(credit)) INTO varDeferredLiabPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				= 'DL'
	AND YEAR(je.entry_date) 				= varYear - 1
;	

--  Code for calculating the EQUITY 

SELECT SUM(coalesce(credit,0) - coalesce(debit,0)) INTO varEquity
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND statement_section_code 				= 'EQ'
	AND YEAR(je.entry_date) 				= varYear
;

SELECT SUM(coalesce(credit,0) - coalesce(debit,0)) INTO varEquityPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND statement_section_code 				= 'EQ'
	AND YEAR(je.entry_date) 				= varYear - 1
;

--  Code for calculating the TOTAL ASSETS 
SELECT SUM(coalesce(debit,0) - coalesce(credit,0)) INTO varTotalAsset
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND statement_section_code 				IN ('CA','FA','DA')
	AND YEAR(je.entry_date) 				= varYear
;

SELECT SUM(coalesce(debit,0) - coalesce(credit,0)) INTO varTotalAssetPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND statement_section_code 				IN ('CA','FA','DA')
	AND YEAR(je.entry_date) 				= varYear -1
;

-- --  Code for calculating the TOTAL LIABILITIES  

SELECT IFNULL(SUM(debit) * -1 +SUM(credit),0) INTO varTotalLiabilities
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				IN ('CL','LLL','DL')
	AND YEAR(je.entry_date) 				= varYear
;

SELECT (SUM(debit) * -1 +SUM(credit)) INTO varTotalLiabilitiesPrevious
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				IN ('CL','LLL','DL')
	AND YEAR(je.entry_date) 				= varYear -1
;

--  Code for calculating the EQUITY + LIABILITY  ***COMMENT: In the year 2017 we identified that the current Assets
-- have a value of 103397.66 and that should be our total assets, however our total assets are 88810.72 causing the BS
-- to be unbalanced, we know that is off but we couldnt find how to correct it, if you identify the problem can you let us know?
-- ALL THE OTHER YEARS BALANCE. 

SELECT IFNULL(SUM(debit) * -1 +SUM(credit),0) INTO varEquityaLiabilities
FROM h_accounting.journal_entry_line_item 	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				IN ('CL','LLL','DL','EQ')
	AND YEAR(je.entry_date) 				= varYear
;

SELECT (SUM(debit) * -1 +SUM(credit)) INTO varEquityaLiabilitiesPrevious
FROM h_accounting.journal_entry_line_item	AS jeli
INNER JOIN h_accounting.`account` 			AS ac ON ac.account_id = jeli.account_id
INNER JOIN h_accounting.journal_entry 		AS je ON je.journal_entry_id = jeli.journal_entry_id
INNER JOIN h_accounting.statement_section 	AS ss ON ss.statement_section_id = ac.balance_sheet_section_id
WHERE ac.balance_sheet_section_id 			<> 0
	AND je.debit_credit_balanced 			= 1
	AND statement_section_code 				IN ('CL','LLL','DL','EQ')
	AND YEAR(je.entry_date) 				= varYear -1
;



-- We then drop out tmp table to be able to create it again. 

DROP TABLE akarlberg_tmp;

-- We create our table with the columns we want and their specifications
	CREATE TABLE akarlberg_tmp
	(statement_number     VARCHAR(50),
	account_name 		  VARCHAR(50),
    current_year 		  VARCHAR(50),
	year_prior 			  VARCHAR(50),
    yoy_change_in_percent VARCHAR(50));
    
-- Giving the columes their order in the table
    INSERT INTO akarlberg_tmp
    (statement_number, account_name, current_year, year_prior, yoy_change_in_percent)
    
    VALUES ('', 'INCOME STATEMENT', '', '', ''),
		   (1, 'REVENUE', ROUND(varTotalRevenues,2), ROUND(varTotalRevenues_previous,2),  ROUND(((varTotalRevenues - varTotalRevenues_previous)
           /varTotalRevenues_previous)*100,2)),
		   (2, 'RRD', ROUND(varRRD,2), ROUND(varRRD_previous,2), ROUND(((varRRD - varRRD_previous)/varRRD_previous)*100,2)), 										 -- RRD stands for RETURNS, REFUNDS, DISCOUNTS
		   (3, 'COGS', ROUND(varCOGS,2),  ROUND(varCOGS_previous,2),  ROUND(((varCOGS - varCOGS_previous)/varCOGS_previous)*100,2)), 								 -- FOR THE GIVEN YEAR AND SUBTRACTING RRD AND COGS 
		   (4, 'GROSS PROFIT',  ROUND((varTotalRevenues - IFNULL(varRRD,0) - varCOGS),2),  ROUND((varTotalRevenues_previous - IFNULL(varRRD_previous,0)  			 -- DERIVING GROSS PROFIT BY TAKING TOTAL REVENUE
           - varCOGS_previous),2), ROUND((((varTotalRevenues - IFNULL(varRRD,0) - varCOGS) - (varTotalRevenues_previous - IFNULL(varRRD_previous,0) 
           - varCOGS_previous))				   						
           /(varTotalRevenues_previous - IFNULL(varRRD_previous,0) - varCOGS_previous))*100,2)), 
           (5, 'ADMIN EXP', ROUND(varAdminExp,2),  ROUND(varAdminExp_previous,2),  ROUND(((varAdminExp - varAdminExp_previous)	 							         -- ADMIN EXP stands for ADMINISTRATIVE EXPENSES
           /varAdminExp_previous)*100,2)), 						 
           (6, 'SELLING EXPENSES',  ROUND(varSellingExp,2),  ROUND(varSellingExp_previous,2), ROUND(((varSellingExp - varSellingExp_previous)                        -- SELLING EXP stands for SELLING EXPENSES
           /varSellingExp_previous)*100,2)),			
           (7, 'OTHER EXPENSES', ROUND(varOtherExp,2),  ROUND(varOtherExp_previous,2), ROUND(((varOtherExp - varOtherExp_previous)/varOtherExp_previous)*100,2)),	 -- OTHER EXP stands for OTHER EXPENSES
           (8, 'OTHER INCOME',  ROUND(varOtherIncome,2),  ROUND(varOtherIncome_previous,2),  ROUND(((varOtherIncome - varOtherIncome_previous)						 -- OTHER INCOME stands for OTHER INCOME
           /varOtherIncome_previous)*100,2)),		
           (9, 'INCOME TAX',  ROUND(varIncomeTax,2),  ROUND(varIncomeTax_previous,2),  ROUND(((varIncomeTax - varIncomeTax_previous)/varIncomeTax_previous)*100,2)), -- CREATING ROW FRO INCOME TAX
           (10, 'OTHER TAX',  ROUND(varOtherTax,2),  ROUND(varOtherTax_previous,2),  ROUND(((varOtherTax - varOtherTax_previous)/varOtherTax_previous)*100,2)), 	 -- CREATING ROW OTHER TAX
          
				-- CREATING THE NET PROFIT FOR THE YEAR OF INTREST
           (11, 'NET PROFIT LOSS',  ROUND((varTotalRevenues - IFNULL(varRRD,0) - varCOGS - IFNULL(varAdminExp,0) - IFNULL(varSellingExp,0) - 					   	 -- DERIVING NET PROFIT OR LOSS BY TAKING TOTAL REVENUE 
           IFNULL(varOtherExp,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0)),2), 						   	 				   		 -- ADDING, OTHER INCOME AND SUBTRACTING RRD, COGS, ADMIN EXP
				-- CREATING THE NET PROFIT FOR  THE YEAR OF INTREST -1 																																											-- ADMIN EXP, SELLING EXP, OTHER EXP, OTHER INCOME, 
		   ROUND((varTotalRevenues_previous - IFNULL(varRRD_previous,0) - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0)							   	 -- INCOME TAX AND OTHER TAX. 
           - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0)),2), 
				-- CREATING THE % CHANGE BETWEEN YEAR OF INTREST AND YEAR OF INTREST -1
		   ROUND((((varTotalRevenues - IFNULL(varRRD,0) - varCOGS - IFNULL(varAdminExp,0) - IFNULL(varSellingExp,0) -
           IFNULL(varOtherExp,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0))
           - (varTotalRevenues_previous - IFNULL(varRRD_previous,0) - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0)
           - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0)))
           /(varTotalRevenues_previous - IFNULL(varRRD_previous,0) - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0)
           - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0)))*100,2)),
           ('', '', '', '', ''),
           ('', 'BALANCE SHEET', '', '', ''),
           (1, 'Current Assets', ROUND(varCurrentAssets,2), ROUND(varCurrentAssetsPrevious,2), ROUND(((varCurrentAssets-varCurrentAssetsPrevious)					-- CREATING ROW FOR CURRENT ASSET 
           /varCurrentAssetsPrevious)*100,2)),
		   (2, 'Fixed Assets', ROUND(varFixedAssets,2), ROUND(varFixedAssetsPrevious,2),''),																		-- CREATING ROW FOR FIXED ASSET
		   (3, 'Deferred Assets', ROUND(varDeferredAssets,2), ROUND(varDeferredAssetsPrevious,2),''),																-- CREATING ROW FOR DEFERRED ASSET
		   (4, 'Current Liabilities', ROUND(varCurrentLiab,2), ROUND(varCurrentLiabPrevious,2),ROUND(((varCurrentLiab-varCurrentLiabPrevious)						-- CREATING ROW FOR CURRENT LIABILITIES
           /varCurrentLiabPrevious)*100,2)),
		   (5, 'Long Term Liabilities', ROUND(varLongTermLiab,2), ROUND(varLongTermLiabPrevious,2),''),																-- CREATING ROW FOR Long Term Liabilities
		   (6, 'Deferred Liabilities', ROUND(varDeferredLiab,2) , ROUND(varDeferredLiabPrevious,2) ,''),															-- CREATING ROW FOR Deferred Liabilities
		   (7, 'Equity', ROUND(varEquity,2), ROUND(varEquityPrevious,2),ROUND(((varEquity-varEquityPrevious)/varEquityPrevious)*100,2)),							-- CREATING ROW FOR Equity
		   (8, 'Total Assets', ROUND(varTotalAsset,2), ROUND(varTotalAssetPrevious,2),ROUND(((varTotalAsset-varTotalAssetPrevious)									-- CREATING ROW FOR Total Assets
           /varTotalAssetPrevious)*100,2)),
	       (9, 'Total Liabilities', ROUND(varTotalLiabilities,2), ROUND(varTotalLiabilitiesPrevious,2),ROUND(((varTotalLiabilities-varTotalLiabilitiesPrevious) 	-- CREATING ROW FOR Total Liabilities
           /varTotalLiabilitiesPrevious)*100,2)),
		   (10, 'Total Equity & Liabilities', ROUND(varEquityaLiabilities,2), ROUND(varEquityaLiabilitiesPrevious,2),												-- CREATING ROW FOR Total Equity & Liabilities
           ROUND(((varEquityaLiabilities-varEquityaLiabilitiesPrevious)/varEquityaLiabilitiesPrevious)*100,2)),
		   ('', '', '', '', ''),
		   ('', 'RATIOS', '', '', ''),
           (1,'Current Ratio', ROUND((varCurrentAssets/varCurrentLiab),2), ROUND((varCurrentAssetsPrevious/varCurrentLiabPrevious),2),								-- CREATING ROW FOR CURRENT RATIO
           ROUND((((varCurrentAssets/varCurrentLiab)-(varCurrentAssetsPrevious/varCurrentLiabPrevious))/(varCurrentAssetsPrevious/
           varCurrentLiabPrevious))*100,2)),
           (2,'D/E Ratio', ROUND((varTotalLiabilities/varEquity),2), ROUND((varTotalLiabilitiesPrevious/varEquityPrevious),2),										-- CREATING ROW FOR D/E Ratio
           ROUND((((varTotalLiabilities/varEquity)-(varTotalLiabilitiesPrevious/varEquityPrevious))/(varTotalLiabilitiesPrevious/varEquityPrevious))*100,2)),		
		   (3,'Return on Equity', ROUND(((varTotalRevenues - IFNULL(varRRD,0) - varCOGS - IFNULL(varAdminExp,0) - IFNULL(varSellingExp,0) - 					   	-- CREATING ROW Return on Equity					
           IFNULL(varOtherExp,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0))/varEquity),2), 
           
           ROUND(((varTotalRevenues_previous - IFNULL(varRRD_previous,0) - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0)							   						
           - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0))/varEquityPrevious),2),
           
           ROUND(((((varTotalRevenues - IFNULL(varRRD,0) - varCOGS - IFNULL(varAdminExp,0) - IFNULL(varSellingExp,0) - 					   						
           IFNULL(varOtherExp,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0))/varEquity)-((varTotalRevenues_previous - 
           IFNULL(varRRD_previous,0) - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0)							   						 
           - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0))/varEquityPrevious))/((varTotalRevenues_previous - IFNULL(varRRD_previous,0) 
           - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0) - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) 
           + IFNULL(varOtherIncome_previous,0) - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0))/varEquityPrevious))*100,2)),
          
          (4,'Return on Assets', ROUND(((varTotalRevenues - IFNULL(varRRD,0) - varCOGS - IFNULL(varAdminExp,0) - IFNULL(varSellingExp,0) - 							-- CREATING ROW Return on Assets
           IFNULL(varOtherExp,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0))/varTotalAsset),2), 
           
           ROUND(((varTotalRevenues_previous - IFNULL(varRRD_previous,0) - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0)							   						
           - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0))/varTotalAssetPrevious),2),
           
           ROUND(((((varTotalRevenues - IFNULL(varRRD,0) - varCOGS - IFNULL(varAdminExp,0) - IFNULL(varSellingExp,0) - 					   						
           IFNULL(varOtherExp,0) + IFNULL(varOtherIncome,0) - IFNULL(varIncomeTax,0) - IFNULL(varOtherTax,0))/varTotalAsset)-((varTotalRevenues_previous - 
           IFNULL(varRRD_previous,0) - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0)							   						 
           - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0))/varTotalAssetPrevious))/((varTotalRevenues_previous - IFNULL(varRRD_previous,0) 
           - IFNULL(varCOGS_previous,0) - IFNULL(varAdminExp_previous,0) - IFNULL(varSellingExp_previous,0) - IFNULL(varOtherExp_previous,0) + IFNULL(varOtherIncome_previous,0)
           - IFNULL(varIncomeTax_previous,0) - IFNULL(varOtherTax_previous,0))/varTotalAssetPrevious))*100,2))
         ;
    

    SELECT * FROM akarlberg_tmp;
    END  $$
     
	DELIMITER ;
