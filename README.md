# Project Statement: Nashville Housing Data Cleaning

In this project, I performed comprehensive data cleaning on the Nashville Housing dataset, focusing on preparing the data for further analysis and ensuring data integrity. The key tasks included:

1. **Date Conversion:** Added and populated a new column `SaleDateConverted` by converting the existing `SaleDate` from string to date format.

2. **Address Normalization:** Filled missing values in the `PropertyAddress` column by self-joining the dataset on `ParcelID` and updating null addresses with corresponding non-null values.

3. **Address Parsing:** Split the `PropertyAddress` and `OwnerAddress` columns into separate columns for street address, city, and state, enabling easier and more granular analysis.

4. **Data Type Modification:** Altered the `SoldAsVacant` column from a bit to a string type (`NVARCHAR(55)`) to replace the values `1` and `0` with more descriptive labels, 'Yes' and 'No'.

5. **Duplicate Removal:** Identified and removed duplicate records based on `ParcelID`, `PropertyAddress`, `SalePrice`, `SaleDate`, and `LegalReference` using a Common Table Expression (CTE).

6. **Column Cleanup:** Dropped unnecessary columns, such as `PropertyAddress`, `OwnerAddress`, and `TaxDistrict`, to streamline the dataset.

This project showcases my ability to handle real-world data issues, such as missing values, data normalization, and duplicate removal, using SQL. The cleaned dataset is now ready for advanced analysis and visualization.

# 
Certainly! Here’s the SQL script with comments added for documentation:


-- Select all records from the Nashville table
```sql
SELECT *
FROM [Project2024].[dbo].[Nashville]
```
-- Convert SaleDate to date format and select it with the new date format
```sql
SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Nashville
```
-- Add a new column SaleDateConverted to store the converted date format
```sql
ALTER TABLE Nashville
ADD SaleDateConverted Date;
```
-- Update the newly added SaleDateConverted column with converted SaleDate values
```sql
UPDATE Nashville
SET SaleDateConverted = CONVERT(date, SaleDate)
```
-- Select all PropertyAddress values that are null to identify missing addresses
```sql
SELECT PropertyAddress
FROM Nashville
WHERE PropertyAddress IS NULL
```
-- Select all records from the Nashville table ordered by ParcelID
```sql
SELECT *
FROM Nashville
ORDER BY ParcelID
```
-- Identify rows where ParcelID is duplicated and PropertyAddress is missing,
-- and join them to another record with the same ParcelID but a valid PropertyAddress
```sql
SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress,
       ISNULL(n1.PropertyAddress, n2.PropertyAddress) AS null_value 
FROM Nashville AS n1
JOIN Nashville AS n2
    ON n1.ParcelID = n2.ParcelID
    AND n1.UniqueID <> n2.UniqueID -- Ensure different records are compared
WHERE n1.PropertyAddress IS NULL
```
-- Update null PropertyAddress values with the corresponding non-null values from the same ParcelID
```sql
UPDATE n1
SET PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM Nashville AS n1
JOIN Nashville AS n2
    ON n1.ParcelID = n2.ParcelID
    AND n1.UniqueID <> n2.UniqueID
WHERE n1.PropertyAddress IS NULL
```
-- Verify if there are still any null PropertyAddress values left
```sql
SELECT PropertyAddress
FROM Nashville
WHERE PropertyAddress IS NULL
```
-- Break out the PropertyAddress into individual columns for address and city
```sql
SELECT PropertyAddress
FROM Nashville
```
-- Extract the address portion from PropertyAddress
```sql
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address,
       SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS city
FROM Nashville
```
-- Add a new column PropertySplitAddress to store the split address part
```sql
ALTER TABLE Nashville
ADD PropertySplitAddress NVARCHAR(255);
```
-- Update PropertySplitAddress with the extracted address portion
```sql
UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
```
-- Add a new column PropertySplitCity to store the split city part
```sql
ALTER TABLE Nashville
ADD PropertySplitCity NVARCHAR(255);
```
-- Update PropertySplitCity with the extracted city portion
```sql
UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
```
-- Verify the update by selecting owner addresses from the Nashville table
```sql
SELECT OwnerAddress
FROM Nashville
```
-- Attempt to extract the parts of OwnerAddress (address, city, state) into separate columns
```sql
SELECT LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1) AS Part1,
       SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress + ',', CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1) AS Part2,
       SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress + ',', CHARINDEX(',', OwnerAddress) + 1) + 1, LEN(OwnerAddress)) AS Part3
FROM Nashville;
```
-- Add a new column OwnerSplitAddress to store the split address part
```sql
ALTER TABLE Nashville
ADD OwnerSplitAddress NVARCHAR(255);
```
-- Update OwnerSplitAddress with the extracted address portion
```sql
UPDATE Nashville
SET OwnerSplitAddress = LEFT(OwnerAddress, CHARINDEX(',', OwnerAddress) - 1)
```

-- Add a new column OwnerSplitCity to store the split city part
```sql
ALTER TABLE Nashville
ADD OwnerSplitCity NVARCHAR(255);
```
-- Update OwnerSplitCity with the extracted city portion
```sql
UPDATE Nashville
SET OwnerSplitCity = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, CHARINDEX(',', OwnerAddress + ',', CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 1)
```
-- Add a new column OwnerSplitState to store the split state part
```sql
ALTER TABLE Nashville
ADD OwnerSplitState NVARCHAR(255);
```
-- Update OwnerSplitState with the extracted state portion
```sql
UPDATE Nashville
SET OwnerSplitState = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress + ',', CHARINDEX(',', OwnerAddress) + 1) + 1, LEN(OwnerAddress))
```
-- Verify the updates by selecting all records from the Nashville table
```sql
SELECT *
FROM Nashville
```
-- Check distinct values in SoldAsVacant to see how many 1s and 0s are present
```sql
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2
```
-- Change the data type of SoldAsVacant from bit to NVARCHAR to allow 'Yes' and 'No' values
ALTER TABLE Nashville
ALTER COLUMN SoldAsVacant NVARCHAR(55);

-- Update SoldAsVacant column to replace '1' with 'Yes' and '0' with 'No'
UPDATE Nashville
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- Remove duplicate records by using a Common Table Expression (CTE) to identify duplicates
WITH Row_Num AS (
SELECT *, 
    ROW_NUMBER() OVER(PARTITION BY 
                        ParcelID, 
                        PropertyAddress,
                        SalePrice,
                        SaleDate,
                        LegalReference
                    ORDER BY UniqueID) AS row_numb
FROM Nashville
)
SELECT *
FROM Row_Num
WHERE row_numb > 1 -- Only select duplicates
ORDER BY PropertyAddress

-- Uncomment the DELETE statement to remove duplicates after verifying the selection
-- DELETE
-- FROM Row_Num
-- WHERE row_numb > 1

-- Select all columns from the Nashville table for inspection
SELECT *
FROM Nashville

-- Drop unused columns from the Nashville table to clean up the dataset
ALTER TABLE Nashville
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
```

This script is now fully documented with comments to explain each step in the data cleaning process.
