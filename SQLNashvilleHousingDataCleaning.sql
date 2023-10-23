SELECT *
FROM [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

--Standardize date format

SELECT SaleDate2, CONVERT(date,saleDate) AS SaleDate2
FROM [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDate2 date;

UPDATE NashvilleHousing
SET SaleDate2 = CONVERT(date,saleDate)

--Populate Property Address Data

SELECT a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [P.projectNashvilleHousing].[dbo].[NashvilleHousing] a
JOIN [P.projectNashvilleHousing].[dbo].[NashvilleHousing] b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [P.projectNashvilleHousing].[dbo].[NashvilleHousing] a
JOIN [P.projectNashvilleHousing].[dbo].[NashvilleHousing] b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

Select OwnerAddress
From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [P.projectNashvilleHousing].[dbo].[NashvilleHousing]

)
DELETE
From RowNumCTE
Where row_num > 1

-- Delete Unused Columns

SELECT *
FROM [P.projectNashvilleHousing].[dbo].[NashvilleHousing]


ALTER TABLE [P.projectNashvilleHousing].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate