/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM [Nashville Housing]

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT [SaleDate], CONVERT(DATE,[SaleDate])
FROM [Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD SaleDateConverted Date;

UPDATE [Nashville Housing]
SET SaleDateConverted = CONVERT(DATE,[SaleDate])

SELECT SaleDateConverted
FROM [Nashville Housing]

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM [Nashville Housing]
-- WHERE [PropertyAddress] IS NULL
ORDER BY [ParcelID]

SELECT A.[ParcelID],A.[PropertyAddress],B.[ParcelID],B.[PropertyAddress],ISNULL(A.[PropertyAddress],B.[PropertyAddress])
FROM [Nashville Housing] A
JOIN [Nashville Housing] B
    ON A.[ParcelID] = B.[ParcelID]
    AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.[PropertyAddress] IS NULL


UPDATE A 
SET [PropertyAddress] = ISNULL(A.[PropertyAddress],B.[PropertyAddress])
FROM [Nashville Housing] A
JOIN [Nashville Housing] B
    ON A.[ParcelID] = B.[ParcelID]
    AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.[PropertyAddress] IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT [PropertyAddress]
FROM [Nashville Housing]
-- FRIST : PropertyAddress
SELECT 
SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1) AS Address,
SUBSTRING([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress])) AS City
FROM [Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD Property_Address NVARCHAR(255);

UPDATE [Nashville Housing]
SET Property_Address = SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1)

ALTER TABLE [Nashville Housing]
ADD Property_City  NVARCHAR(255);

UPDATE [Nashville Housing]
SET Property_City = SUBSTRING([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress]))


SELECT[OwnerAddress]
FROM [Nashville Housing]

-- SECOND : OwnerAddress

SELECT 
PARSENAME(REPLACE([OwnerAddress],',','.'),3) AS Address ,
PARSENAME(REPLACE([OwnerAddress],',','.'),2) AS City,
PARSENAME(REPLACE([OwnerAddress],',','.'),1) AS State
FROM [Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD Owner_Address NVARCHAR(255);

UPDATE [Nashville Housing]
SET Owner_Address = PARSENAME(REPLACE([OwnerAddress],',','.'),3)

ALTER TABLE [Nashville Housing]
ADD Owner_City NVARCHAR(255);

UPDATE [Nashville Housing]
SET Owner_City = PARSENAME(REPLACE([OwnerAddress],',','.'),2)

ALTER TABLE [Nashville Housing]
ADD Owner_State NVARCHAR(255);

UPDATE [Nashville Housing]
SET Owner_State = PARSENAME(REPLACE([OwnerAddress],',','.'),1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT ([SoldAsVacant]), COUNT([SoldAsVacant])
FROM [Nashville Housing]
GROUP BY [SoldAsVacant]

SELECT [SoldAsVacant],
   CASE WHEN [SoldAsVacant] ='Y' THEN 'Yes'
        WHEN [SoldAsVacant] ='N' THEN 'No'
		ELSE [SoldAsVacant]
		END
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET [SoldAsVacant] = CASE WHEN [SoldAsVacant] ='Y' THEN 'Yes'
                          WHEN [SoldAsVacant] ='N' THEN 'No'
		                  ELSE [SoldAsVacant]
		                  END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH ROW_NUM_CTE AS(
SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY [ParcelID],
               [PropertyAddress],
			   [SalePrice],
			   [SaleDate],
			   [LegalReference]
ORDER BY [UniqueID ]) AS ROW_NUM
FROM [Nashville Housing]
)

SELECT *
FROM ROW_NUM_CTE
WHERE ROW_NUM >1


WITH ROW_NUM_CTE AS(
SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY [ParcelID],
               [PropertyAddress],
			   [SalePrice],
			   [SaleDate],
			   [LegalReference]
ORDER BY [UniqueID ]) AS ROW_NUM
FROM [Nashville Housing]
)

DELETE 
FROM ROW_NUM_CTE
WHERE ROW_NUM >1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM [Nashville Housing]


ALTER TABLE [Nashville Housing]
DROP COLUMN [OwnerAddress],[TaxDistrict],[PropertyAddress],[SaleDate]
