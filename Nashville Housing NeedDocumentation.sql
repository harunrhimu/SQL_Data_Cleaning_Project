
SELECT *
FROM [Project2024].[dbo].[Nashville]



select SaleDateConverted, convert(date, SaleDate)
from Nashville

ALTER TABLE Nashville
ADD SaleDateConverted Date;

update Nashville
set SaleDateConverted = convert(date, SaleDate)

--Populate Property Address data
select PropertyAddress
from Nashville
where PropertyAddress is null

select *
from Nashville
--where PropertyAddress is null
order by ParcelID
--there are double percel id
--if this percel id has address and this (double one) has no address bu populated with others
--self join 

select n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress
--is null called if n1.PropertyAddress is null then n2.PropertyAddress will be populated			
			, ISNULL(/*if n1 is null*/n1.PropertyAddress, /*populated with n2*/n2.PropertyAddress) as null_value 
from Nashville as n1
join Nashville as n2
	On n1.ParcelID = n2.ParcelID
	and n1.UniqueID <> n2.UniqueID --play if n1=n2 than what? except <> not equal
where n1.PropertyAddress is null


--update null with real address

update n1
 set PropertyAddress = ISNULL(/*if n1 is null*/n1.PropertyAddress, /*populated with n2*/n2.PropertyAddress) 
 from Nashville as n1
join Nashville as n2
	On n1.ParcelID = n2.ParcelID
	and n1.UniqueID <> n2.UniqueID
where n1.PropertyAddress is null

--see is null present 
select PropertyAddress
from Nashville
where PropertyAddress is  null

--Breaking out address into individual column ( address, city, state)
select PropertyAddress
from Nashville


SELECT SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as addresss
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1 , LEN(propertyaddress)) as city
--CHARINDEX(',', propertyaddress) --this is just position

from Nashville

--update table with new column address and city 

ALTER TABLE Nashville
ADD PropertySplitAddress nvarchar(255);

update Nashville
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) --use formula here

ALTER TABLE Nashville
ADD PropertySplitCity nvarchar(255);

update Nashville
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1 , LEN(propertyaddress)) --use formula here

--to see what updated in the last of the  main table

select owneraddress
from Nashville


SELECT SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as addresss
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1 , LEN(propertyaddress)) as city
--CHARINDEX(',', propertyaddress) --this is just position

select OwnerAddress
from Nashville

--this below formula not work as i got the lesson
--select 
--PARSENAME(replace(owneraddress,',',','), 1),
--PARSENAME(replace(owneraddress,',',','), 2),
--PARSENAME(replace(owneraddress,',',','), 3)
--from  Nashville

SELECT
    LEFT(owneraddress, CHARINDEX(',', owneraddress) - 1) AS Part1,
    SUBSTRING(owneraddress, CHARINDEX(',', owneraddress) + 1, CHARINDEX(',', owneraddress + ',', CHARINDEX(',', owneraddress) + 1) - CHARINDEX(',', owneraddress) - 1) AS Part2,
    SUBSTRING(owneraddress, CHARINDEX(',', owneraddress + ',', CHARINDEX(',', owneraddress) + 1) + 1, LEN(owneraddress)) AS Part3
FROM
    Nashville;


--update table with new column address and city 

ALTER TABLE Nashville
ADD OwnerSplitAddress nvarchar(255);

update Nashville
set OwnerSplitAddress = LEFT(owneraddress, CHARINDEX(',', owneraddress) - 1) --use formula here

ALTER TABLE Nashville
ADD OwnerSplitCity nvarchar(255);

update Nashville
set OwnerSplitCity = SUBSTRING(owneraddress, CHARINDEX(',', owneraddress) + 1, CHARINDEX(',', owneraddress + ',', CHARINDEX(',', owneraddress) + 1) - CHARINDEX(',', owneraddress) - 1) --use formula here


ALTER TABLE Nashville
ADD OwnerSplitState nvarchar(255);

update Nashville
set OwnerSplitState = SUBSTRING(owneraddress, CHARINDEX(',', owneraddress + ',', CHARINDEX(',', owneraddress) + 1) + 1, LEN(owneraddress)) --use formula here

--to see what updated in the last of the  main table

select *
from Nashville


--change 1 and 0 to yes and no in "SoldAsVacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nashville
group by SoldAsVacant
order by 2 --2 for result table not real table



--------------we faced a issue to change value 1 and 0 t yes and no because of our column in (bit) type so we have to alter table to change it nvarchar(55) and update table with case statement
-- Step 1: Change the column type
ALTER TABLE Nashville
ALTER COLUMN SoldAsVacant NVARCHAR(55);

-- Step 2: Update values to 'Yes' and 'No'
UPDATE Nashville
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;


--Remove duplicate
WITH Row_Num AS (
select *, 
	ROW_NUMBER() OVER( PARTITION BY 
				ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY uniqueID) as row_numb
from Nashville
--order by ParcelID  CTE not support order by 
)
select *
FROM Row_Num
where row_numb >1
order by PropertyAddress

--DELETE
--FROM Row_Num
--where row_numb >1

--Delete Unused Columns

Select *
from Nashville

ALTER TABLE Nashville
DROP COLUMN --PropertyAddress, OwnerAddress, TaxDistrict





















































































































