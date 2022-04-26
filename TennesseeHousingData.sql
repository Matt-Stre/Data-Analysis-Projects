SELECT *
FROM Nashville.dbo.Housing

--Corrects sale date
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Nashville.dbo.Housing

ALTER TABLE Nashville.dbo.Housing
ADD SaleDateUpdated Date;

Update Nashville.dbo.Housing
SET SaleDateUpdated = CONVERT(Date, SaleDate)

--Populate Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress) 
FROM Nashville.dbo.Housing a
JOIN Nashville.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress) 
FROM Nashville.dbo.Housing a
JOIN Nashville.dbo.Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Separating PropertyAddress Column into Multiple Columns
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM Nashville.dbo.Housing

ALTER TABLE Nashville.dbo.Housing
ADD StreetAddress nvarchar(255);

Update Nashville.dbo.Housing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville.dbo.Housing
ADD City nvarchar(255);

Update Nashville.dbo.Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Separating OwnerAddress Column into Multiple Columns
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerStreet
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerState
FROM Nashville.dbo.Housing

ALTER TABLE Nashville.dbo.Housing
ADD OwnerStreet nvarchar(255);

Update Nashville.dbo.Housing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashville.dbo.Housing
ADD OwnerCity nvarchar(255);

Update Nashville.dbo.Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashville.dbo.Housing
ADD OwnerState nvarchar(255);

Update Nashville.dbo.Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Modify SoldAsVacant Column Name and Standardizing Values
SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
FROM Nashville.dbo.Housing

Update Nashville.dbo.Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END


--Removing Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Nashville.dbo.Housing
)
DELETE
From RowNumCTE
Where row_num > 1


--Deleting extra columns that were split above
ALTER TABLE Nashville.dbo.Housing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate