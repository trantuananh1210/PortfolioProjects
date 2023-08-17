SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
FROM [NashvilleHousing].[dbo].[Nashville Housing Data for Data Cleaning]

SELECT * from NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]

  -- Standardize Date Format
SELECT SaleDate, CONVERT(date, SaleDate) as SaleDateConvert
from NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
ADD SaleDateConverted DATE;
UPDATE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate property address data
select * from NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
WHERE PropertyAddress is NULL

SELECT * FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
ORDER BY ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning] as a
JOIN NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning] as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning] as a
JOIN NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning] as b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT *
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
-----------------------------------------------------------------------------------------------
ALTER TABLE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
-----------------------------------------------------------------------------------------------
ALTER TABLE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]

SELECT DISTINCT SoldAsVacant, COUNT (SoldAsVacant)
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]

UPDATE NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

-- Remove duplicates
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID
) row_num
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
ORDER BY ParcelID
-----------------------------------------------------------------------------------------------
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID
) row_num
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress
-----------------------------------------------------------------------------------------------
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID
) row_num
FROM NashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
-----------------------------------------------------------------------------------------------
-- Delete Unused Columns
ALTER TABLE ashvilleHousing.dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate