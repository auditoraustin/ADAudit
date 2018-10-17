
-- #############################################################################
-- Most Recent SQL SampleQueries for IT Audit Testwork
-- #############################################################################
-- =============================================================================

-- Purpose: Provide sample queries for Auditors to use


-- ########################################################################################################

-- AD Query 11 | Active Directory (AD) Users Recap: From Custom Query
-- Purpose: To provide a count of how many accounts are in AD & the status of these accounts.

 -- Active Directory Query 11
SELECT COUNT(*) AS 'Count', [userAccountControl]
FROM [Test_AD_Users]
GROUP BY [userAccountControl]
ORDER BY [userAccountControl]




-- ########################################################################################################

-- AD Query 2 | HR & Terminated User Clean-Up: From SampleQueries - Sample Query 1
-- Purpose: To compare the Agency's provided Employee List and Terminated User List and to remove any
--          duplicates found between the 2 lists and use the updated lists for the testwork below.

 -- Active Directory Query 2
SELECT 
    CASE
        WHEN t2.[Term Date] > CONVERT(DATETIME,'INSERT DATE AD SCRIPT WAS RUN') THEN 'Employee is not terminated at the time of report being run'
        ELSE ''
    END AS 'TermEmployeeStatus',
    t1.*,t2.*
FROM [Test_Current_Employees] AS t1
    INNER JOIN [Test_Terminated_Employees] AS t2
        ON t1.[Last Name] LIKE t2.[L_Name] AND t1.[First Name] LIKE t2.[F_Name]
    --Determine if the Agency uses """"""""EmployeeNumber"""""""" or """"""""employeeID"""""""" between
    --Systems.  Otherwise use the name comparison
--WHERE --Use this area to filter out items if [District/Agency] are doing anything
--special with their process or data keeping of the lists.
ORDER BY t1.[LastName] ASC




-- ########################################################################################################

-- AD Query 7 | AD Accounts Associated with Terminated Employee: From SampleQueries - Sample Query 6
-- Purpose: To determine what AD accounts are not associated with a current employee.

 -- Active Directory Query 7
SELECT 
        t1.[displayName], t1.[givenName] AS 'First Name (givenName)', 
        t1.[sn] AS 'Last Name (sn)', t1.[cn],  
        t1.[lastLogonDate], t1.[title], t1.[department],
        t1.[description], t1.[memberOf],
        t1.[sAMAccountName] AS 'Username (sAMAccountName)',
        t1.[name],  t1.[primaryGroupID],
        t1.[whenCreated], t1.[passwordLastSet], t1.[whenChanged],   
        t1.[accountExpirationDate], t1.[userAccountControl], 
        t1.[msDS-User-Account-Control-Computed], 
        t1.[msDS-UserPasswordExpiryTimeComputed],
        t1.[relativeIdentifier], 
        t1.[distinguishedName], t1.[employeeNumber], t1.[employeeID],
        t2.*
FROM [Test_AD_Users] AS t1
    RIGHT JOIN [Test_Terminated_Employees] AS t2
    ON t1.[sn] LIKE t2.[L_Name] AND t1.[givenName] LIKE t2.[F_Name]
    --Determine if the Agency uses ""EmployeeNumber"" or ""employeeID"" between
    --Systems.  Otherwise use the name comparison
WHERE (t1.userAccountControl LIKE 'Enabled%' AND (t1.[accountExpirationDate] LIKE ''
        OR CONVERT(DATETIME,t1.[accountExpirationDate]) >= CONVERT(DATETIME,'INSERT DATE AD SCRIPT WAS RUN')))
ORDER BY t1.[sn] ASC




-- ########################################################################################################

-- AD Query 9 | Account Disabling Testwork: From SampleQueries - Sample Query 8
-- Purpose: To determine if any Active Directory accounts have not signed into AD within the past 
--          [Agency Specified time] days and determine if accounts are needed.

 -- Active Directory Query 9
SELECT 
        DATEDIFF(DAY,CONVERT(DATE,t1.[lastLogonDate]),CONVERT(DATE,'INSERT DATE AD SCRIPT WAS RUN')) AS 'DaysSinceLastLogin',
        t1.[givenName] AS 'First Name (givenName)', 
        t1.[sn] AS 'Last Name (sn)', 
        t1.[name], t1.[department], t1.[title], t1.[description],
        t1.[memberOf], t1.[primaryGroupID],
        t1.[whenCreated], t1.[passwordLastSet],
        t1.[lastLogonDate], 
        CASE
            WHEN t1.[lastLogonDate] LIKE '' THEN 'Account may not have ever logged in to network'
            ELSE t1.[lastLogonDate]
        END AS 'Calc-lastLogonDate',
        t1.[whenChanged], 
        t1.[accountExpirationDate], t1.[userAccountControl], 
        t1.[msDS-User-Account-Control-Computed], 
        t1.[msDS-UserPasswordExpiryTimeComputed],
        t1.[relativeIdentifier],  t1.[distinguishedName],
        t1.[cn], t1.[sAMAccountName] AS 'Username (sAMAccountName)',
        t1.[displayName], t1.[employeeNumber], t1.[employeeID]
FROM [Test_AD_Users] AS t1
WHERE (t1.userAccountControl LIKE 'Enabled%' AND (t1.[accountExpirationDate] LIKE '' 
        OR CONVERT(DATETIME,t1.[accountExpirationDate]) >= CONVERT(DATETIME,'INSERT DATE AD SCRIPT WAS RUN'))) 
        AND
        (CAST(CONVERT(DATETIME, 'INSERT DATE AD SCRIPT WAS RUN') - t1.[lastLogonDate] AS INT) > 'INSERT # DEFINED BY ENTITY'
        OR t1.[lastLogonDate] LIKE '')
ORDER BY 'DaysSinceLastLogin' DESC




-- ########################################################################################################

-- AD Query 13 | Fine Grain Password Policy (FGPP) Recap: From Custom Query
-- Purpose: To determine how many accounts are associated with FGPP & the Default Domain Password Policy.

 -- Active Directory Query 13
SELECT COUNT(*) AS 'Count',
    CASE
        WHEN [msds-resultantPSO] LIKE '' THEN 'Default Password Policy'
        ELSE [msds-resultantPSO]
    END AS [msds-resultantPSO]
FROM [Test_AD_Users]
WHERE [userAccountControl] LIKE '%Enabled%'
GROUP BY [msDS-ResultantPSO]




-- ########################################################################################################

-- AD Query 12 | FGPP Recap: From Custom Query
-- Purpose: To determine how many accounts have the UAC set to not expire.

 -- Active Directory Query 12
SELECT COUNT(*) AS 'Count', [userAccountControl],
    CASE
        WHEN [msds-resultantPSO] LIKE '' THEN 'Default Password Policy'
        ELSE [msds-resultantPSO]
    END AS [msds-resultantPSO]
FROM [Test_AD_Users]
WHERE [userAccountControl] LIKE '%Enabled%' 
        AND [userAccountControl] LIKE '%Password Does Not Expire%'
GROUP BY [msDS-ResultantPSO], [userAccountControl]
ORDER BY [msds-resultantPSO], [userAccountControl] 




-- ########################################################################################################

-- AD Query 15 | FGPP Recap: From Custom Query
-- Purpose: To determine how many staff accounts are associated with a FGPP.

 -- Active Directory Query 15
SELECT COUNT(*) AS 'Count',
    CASE
        WHEN [msds-resultantPSO] LIKE '' THEN 'Default Password Policy'
        ELSE [msds-resultantPSO]
    END AS [msds-resultantPSO]
FROM [Test_AD_Users]
WHERE [userAccountControl] LIKE '%Enabled%' 
        AND  ([INSERT WHAT DESIGNATES AN EMPLOYEE ACCOUNT])
GROUP BY [msDS-ResultantPSO]
ORDER BY [msds-resultantPSO]




-- ########################################################################################################

-- AD Query 14 | FGPP Recap: From Custom Query
-- Purpose: To determine how many staff accounts are associated with a FGPP that have their UAC set to not
--          have their password's expire.

 -- Active Directory Query 14
SELECT COUNT(*) AS 'Count',
    CASE
        WHEN [msds-resultantPSO] LIKE '' THEN 'Default Password Policy'
        ELSE [msds-resultantPSO]
    END AS [msds-resultantPSO]
FROM [Test_AD_Users]
WHERE [userAccountControl] LIKE '%Enabled%' 
        AND [userAccountControl] LIKE '%Password Does Not Expire%'
        AND ([INSERT WHAT DESIGNATES AN EMPLOYEE ACCOUNT])
GROUP BY [msDS-ResultantPSO]
ORDER BY [msds-resultantPSO]




-- ########################################################################################################

-- AD Query 5 | Password Expiration Testwork: From SampleQueries - Sample Query 4
-- Purpose: To ensure that passwords are being changed at the [Agency Defined] time period.

 -- Active Directory Query 5
SELECT
    CASE
        WHEN [msds-resultantPSO] LIKE '' THEN 'Default Password Policy'
        ELSE [msds-resultantPSO]
    END AS [msds-resultantPSO],
    t1.[LastLogonDate],
    CASE
        WHEN t1.[lastLogonDate] LIKE '' THEN 'Account may not have ever logged in to network'
        ELSE t1.[LastLogonDate] 
    END AS 'Calc-LastLogonDate',
    t1.[msDS-UserPasswordExpiryTimeComputed],
    CASE 
        WHEN t1.[msDS-UserPasswordExpiryTimeComputed] LIKE '' THEN 'Password Does Not Expire'
        WHEN t1.[msDS-UserPasswordExpiryTimeComputed] LIKE '%12/31/1600%' THEN 'Password Not Set'
        ELSE t1.[msDS-UserPasswordExpiryTimeComputed]
    END AS 'Calc-msDS-UserPasswordExpiryTimeComputed',
    CASE 
        WHEN t1.[msDS-UserPasswordExpiryTimeComputed] = '' THEN ''
        WHEN t1.[PasswordLastSet] = ''  THEN ''
        ELSE DATEDIFF(DAY,CONVERT(DATE,t1.[passwordLastSet]),CONVERT(DATE,t1.[msDS-UserPasswordExpiryTimeComputed]))
    END AS 'PasswordExpirationSetting',
    t1.[userAccountControl], t1.[accountExpirationDate], t1.[PasswordLastSet],
    CASE 
        WHEN t1.[PasswordLastSet] LIKE '' AND t1.[userAccountControl] NOT LIKE '%Password Does Not Expire%' THEN 'Password Must Be Set On Next Logon'
        ELSE t1.[PasswordLastSet]
    END AS 'Calc-PasswordLastSet',
    t1.[givenName] AS 'First Name (givenName)', 
    t1.[sn] AS 'Last Name (sn)', t1.[cn],
    t1.[DistinguishedName], t1.[displayName], 
    t1.[sAMAccountName] AS 'Username (sAMAccountName)', t1.[name],
    t1.[relativeIdentifier], t1.[department], t1.[msDS-User-Account-Control-Computed],
    CASE
        WHEN t1.[PasswordLastSet] LIKE '' AND t1.[userAccountControl] LIKE '%Password Not Required%' THEN 'Password is Blank!'
        ELSE t1.[msDS-User-Account-Control-Computed]
    END AS 'Calc-msDS-User-Account-Control-Computed',
    t1.[employeeNumber], t1.[employeeID]
FROM [Test_AD_Users] AS t1
WHERE (t1.[userAccountControl] LIKE 'Enabled%')
AND (CAST(CONVERT(DATETIME, 'INSERT DATE AD SCRIPT WAS RUN') - t1.[passwordLastSet] AS INT) > 'INSERT # DEFINED BY ENTITY')
ORDER BY [msDS-ResultantPSO] DESC, 'PasswordExpirationSetting' ASC




-- ########################################################################################################

-- AD Query 16 | Password Expiration Testwork (service Accounts): From SampleQueries - ????
-- Purpose: To ensure that passwords are being changed for service accounts when an IT employee leaves the [Agency/District].

 -- Active Directory Query 16
SELECT 
    CASE
        WHEN [msds-resultantPSO] LIKE '' THEN 'Default Password Policy'
        ELSE [msds-resultantPSO]
    END AS [msds-resultantPSO],
    t1.[lastLogonDate], 
    CASE
        WHEN t1.[lastLogonDate] LIKE '' THEN 'Account may not have ever logged in to network'
        ELSE t1.[LastLogonDate] 
    END AS 'Calc-LastLogonDate',
    t1.[msDS-UserPasswordExpiryTimeComputed],
    CASE 
        WHEN t1.[msDS-UserPasswordExpiryTimeComputed] LIKE '' THEN 'Password Does Not Expire'
        WHEN t1.[msDS-UserPasswordExpiryTimeComputed] LIKE '%12/31/1600%' THEN 'Password Not Set'
        ELSE t1.[msDS-UserPasswordExpiryTimeComputed]
    END AS 'Calc-msDS-UserPasswordExpiryTimeComputed',
    CASE 
        WHEN t1.[msDS-UserPasswordExpiryTimeComputed] = '' THEN ''
        WHEN t1.[PasswordLastSet] = ''  THEN ''
        ELSE DATEDIFF(DAY,CONVERT(DATE,t1.[passwordLastSet]),CONVERT(DATE,t1.[msDS-UserPasswordExpiryTimeComputed]))
    END AS 'PasswordExpirationSetting',
    t1.[userAccountControl], t1.[accountExpirationDate], t1.[PasswordLastSet],
    CASE 
        WHEN t1.[PasswordLastSet] LIKE '' AND t1.[userAccountControl] NOT LIKE '%Password Does Not Expire%' THEN 'Password Must Be Set On Next Logon'
        ELSE t1.[PasswordLastSet]
    END AS 'Calc-PasswordLastSet',
    CASE 
        WHEN DATEDIFF(DAY,CONVERT(DATE,t1.[passwordLastSet]),CONVERT(DATE,'INSERT DATE OF IT EMPLOYEE TERM LIST')) > 0 OR t1.[passwordLastSet] LIKE ''
        THEN DATEDIFF(DAY,CONVERT(DATE,t1.[passwordLastSet]),CONVERT(DATE,'INSERT DATE OF IT EMPLOYEE TERM LIST')) 
        ELSE 0 
    END AS 'DaysEx-EmployeeKnowsPassword',
    t1.[givenName] AS 'First Name (givenName)', 
    t1.[sn] AS 'Last Name (sn)', t1.[cn],
    t1.[DistinguishedName], t1.[displayName], 
    t1.[sAMAccountName] AS 'Username (sAMAccountName)', t1.[name],
    t1.[relativeIdentifier], t1.[department], t1.[msDS-User-Account-Control-Computed],
    CASE
        WHEN t1.[PasswordLastSet] LIKE '' AND t1.[userAccountControl] LIKE '%Password Not Required%' THEN 'Password is Blank!'
        ELSE t1.[msDS-User-Account-Control-Computed]
    END AS 'msDS-User-Account-Control-Computed',
    t1.[employeeNumber], t1.[employeeID]
FROM [Test_AD_Users] AS t1
WHERE (t1.[userAccountControl] LIKE 'Enabled%')
--AND [INSERT INFORMATION THAT DISTINGUISHES REGULAR ACCOUNTS FROM SERVICE ACCOUNTS]
ORDER BY [DaysEx-EmployeeKnowsPassword] DESC




-- ########################################################################################################

-- AD Query 3 | Active Directory Group Administrators: From SampleQueries - Sample Query 2
-- Purpose: To find the list of administrators in the system and determine if the accounts are appropriate.

 -- Active Directory Query 3
SELECT 
        t1.[cn], t1.[name], t1.[RelativeIdentifier] AS 'PrimaryGroupID',
        t1.[description], t1.[sAMAccountName],
        t1.[memberOf], t1.[displayName]
FROM [Test_AD_Groups] AS t1
WHERE t1.[memberOf] LIKE '%, Administrators%' OR
        t1.[memberOf] LIKE 'Administrators, %' OR
        t1.[memberOf] LIKE 'Administrators' OR
        t1.[memberOf] LIKE '%Domain Admins%' OR 
        t1.[memberOf] LIKE '%Enterprise Admins%' OR
        t1.[memberOf] LIKE '%Schema Admins%' OR
        t1.[memberOf] LIKE '%Server Operators%' OR
        t1.[memberOf] LIKE '%Backup Operators%' OR
        t1.[memberOf] LIKE '%Account Operators%'




-- ########################################################################################################

-- AD Query 4 | Active Directory User Administrators: From SampleQueries - Sample Query 3
-- Purpose: To find the list of administrators in the system and determine if the accounts are appropriate.

 -- Active Directory Query 4
SELECT 
        t1.[DistinguishedName], t1.[displayName], t1.[givenName] AS 'First Name (givenName)', 
        t1.[sn] AS 'Last Name (sn)', t1.[cn],  
        t1.[sAMAccountName] AS 'Username (sAMAccountName)',
        t1.[name], t1.[memberOf], t1.[primaryGroupID],
        t1.[title], t1.[description], t1.[whenCreated], t1.[passwordLastSet],
        t1.[lastLogonDate], t1.[whenChanged],   
        t1.[accountExpirationDate], t1.[userAccountControl], 
        t1.[msDS-User-Account-Control-Computed], 
        t1.[msDS-UserPasswordExpiryTimeComputed],
        t1.[objectSid], t1.[relativeIdentifier], 
        t1.[department], t1.[employeeNumber], t1.[employeeID],
        (CASE WHEN t1.[memberOf] LIKE '%, Administrators%' OR t1.[memberOf] LIKE 'Administrators,%'
        OR t1.primaryGroupID LIKE '544' THEN 'Administrators, ' ELSE '' END)
        + (CASE WHEN t1.[memberOf] LIKE '%Domain Admins%' OR t1.primaryGroupID LIKE '512' THEN 'Domain Admins, ' ELSE '' END)
        + (CASE WHEN t1.[memberOf] LIKE '%Enterprise Admins%' OR t1.primaryGroupID LIKE '519' THEN 'Enterprise Admins, ' ELSE '' END)
        + (CASE WHEN t1.[memberOf] LIKE '%Schema Admins%' OR t1.primaryGroupID LIKE '518' THEN 'Schema Admins, ' ELSE '' END)
        + (CASE WHEN t1.[memberOf] LIKE '%Server Operators%' OR t1.primaryGroupID LIKE '549' THEN 'Server Operators, ' ELSE '' END)
        + (CASE WHEN t1.[memberOf] LIKE '%Backup Operators%' OR t1.primaryGroupID LIKE '551' THEN 'Backup Operators, ' ELSE '' END)
        + (CASE WHEN t1.[memberOf] LIKE '%Account Operators%' OR t1.primaryGroupID LIKE '548' THEN 'Account Operators, ' ELSE '' END)
             AS 'administrativeGroups'
FROM [Test_AD_Users] AS t1 
WHERE (t1.userAccountControl LIKE 'Enabled%' AND (t1.[accountExpirationDate] LIKE ''  
       OR CONVERT(DATETIME,t1.[accountExpirationDate]) >= CONVERT(DATETIME,'INSERT DATE AD SCRIPT WAS RUN')))
AND
 (
        t1.[memberOf] LIKE '%, Administrators%' OR
        t1.[memberOf] LIKE 'Administrators, %' OR
        t1.[memberOf] LIKE 'Administrators' OR
        t1.[primaryGroupID] LIKE '544' OR
        t1.[memberOf] LIKE '%Domain Admins%' OR
        t1.[primaryGroupID] LIKE '512' OR
        t1.[memberOf] LIKE '%Enterprise Admins%' OR
        t1.[primaryGroupID] LIKE '519' OR
        t1.[memberof] LIKE '%Schema Admins%' OR
        t1.[primaryGroupID] LIKE '518' OR
        t1.[memberof] LIKE '%Server Operators%' OR
        t1.[primaryGroupID] LIKE '549' OR
        t1.[memberof] LIKE '%Backup Operators%' OR
        t1.[primaryGroupID] LIKE '551' OR
        t1.[memberof] LIKE '%Account Operators%' OR
        t1.[primaryGroupID] LIKE '548'
        )
ORDER BY t1.[sn] ASC




-- ########################################################################################################

-- AD Query 10 | External Connections Access: From SampleQueries - Sample Query 9
-- Purpose: To determine what accounts are used to connect to the internal network from the internet and if 
--          these accounts are associated with a current employee.

 -- Active Directory Query 10
SELECT 
        t1.*
        --,t2.*
FROM [Test_VPN_Users] AS t1
    LEFT JOIN [Test_Current_Employees] AS t2
        ON t1.[sn] = t2.[Last Name] AND t1.[givenName] = t2.[First Name]
WHERE (t2.[Last Name] IS NULL OR t2.[First Name] IS NULL)
      --[Insert Criteria if Needed, If None Delete Preceding AND]
ORDER BY t1.[sn] ASC




-- ########################################################################################################

-- AD Query 8 | Non-Matched Accounts: From SampleQueries - Sample Query 7
-- Purpose: To determine what AD accounts are not associated with a current or terminated employee.

 -- Active Directory Query 8
SELECT 
        t1.[displayName], t1.[givenName] AS 'First Name (givenName)', 
        t1.[sn] AS 'Last Name (sn)', t1.[cn],  
        t1.[lastLogonDate], t1.[title], t1.[department],
        t1.[description], t1.[memberOf],
        t1.[sAMAccountName] AS 'Username (sAMAccountName)',
        t1.[name],  t1.[primaryGroupID],
        t1.[whenCreated], t1.[passwordLastSet], t1.[whenChanged],   
        t1.[accountExpirationDate], t1.[userAccountControl], 
        t1.[msDS-User-Account-Control-Computed], 
        t1.[msDS-UserPasswordExpiryTimeComputed],
        t1.[relativeIdentifier], 
        t1.[distinguishedName], t1.[employeeNumber], t1.[employeeID]
        --,t2.*, t3.*
FROM [Test_AD_Users] AS t1
    LEFT JOIN [Test_Current_Employees] AS t2
        ON t1.[sn] = t2.[Last Name] AND t1.[givenName] = t2.[First Name]
    LEFT JOIN [Test_Terminated_Employees] AS t3
        ON t1.[sn] = t3.[L_Name] AND t1.[givenName] = t3.[F_Name]
    --Determine if the Agency uses """"EmployeeNumber"""" or """"employeeID"""" between
    --Systems.  Otherwise use the name comparison
WHERE ((t2.[Last Name] IS NULL OR t2.[First Name] IS NULL)
        AND
        (t3.[L_Name] IS NULL OR t3.[F_Name] IS NULL))
        AND
        (t1.userAccountControl LIKE 'Enabled%' AND (t1.[accountExpirationDate] LIKE ''
        OR CONVERT(DATETIME,t1.[accountExpirationDate]) >= CONVERT(DATETIME,'INSERT DATE AD SCRIPT WAS RUN')))
ORDER BY t1.[sn] ASC




-- ########################################################################################################

-- AD Query 1 | Active Directory Password Policy: From SampleQueries - Sample Query 10
-- Purpose: To determine the password policy that is in effect at the agency.

 -- Active Directory Query 1
SELECT
    CASE
        WHEN [msds-resultantPSO] LIKE '' THEN 'Default Password Policy'
        ELSE [msds-resultantPSO]
    END AS [msds-resultantPSO], 
    t1.[msDS-UserPasswordExpiryTimeComputed],
    CASE 
        WHEN t1.[msDS-UserPasswordExpiryTimeComputed] = '' THEN ''
        WHEN t1.[PasswordLastSet] = '' THEN ''
        ELSE DATEDIFF(DAY,CONVERT(DATE,t1.[passwordLastSet]),CONVERT(DATE,t1.[msDS-UserPasswordExpiryTimeComputed]))
    END AS 'PasswordExpirationSetting',
    t1.[userAccountControl], t1.[accountExpirationDate], t1.[PasswordLastSet], 
    t1.[givenName] AS 'First Name (givenName)', 
    t1.[sn] AS 'Last Name (sn)', t1.[cn],
    t1.[DistinguishedName], t1.[displayName], 
    t1.[sAMAccountName] AS 'Username (sAMAccountName)', t1.[name],
    t1.[relativeIdentifier], t1.[department], 
    t1.[employeeNumber], t1.[employeeID]
FROM [Test_AD_Users] AS t1
WHERE (t1.[userAccountControl] LIKE 'Enabled%')
ORDER BY [msDS-ResultantPSO] DESC, 'PasswordExpirationSetting' ASC




-- ########################################################################################################
