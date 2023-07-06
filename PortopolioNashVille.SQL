/*
CLEANING DATA IN SQL QUERY
*/


SELECT *
FROM PortpolioNashville..NashvilleHouse

------------------------------------------------------

-- STANDARDIZE DATE FORMAT
-- MERUBAH FORMAT DATE PADA KOLOM SALEDATE

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortpolioNashville..NashvilleHouse

ALTER TABLE NashvilleHouse
ADD SaleDateConverted DATE;

UPDATE NashvilleHouse
SET SaleDateConverted = CONVERT(DATE, SaleDate)

------------------------------------------------------

--populate property address data
-- jadi kita mau lihat data dari colomn propertyaddress apakah ada yang null atau tidak
-- jika ada kita bisa merubahnya sesuai data yang tersedia


SELECT *
FROM PortpolioNashville..NashvilleHouse
--WHERE PropertyAddress IS NULL
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortpolioNashville..NashvilleHouse a,
PortpolioNashville..NashvilleHouse b 
WHERE	a.ParcelID = b.ParcelID 
		AND a.[UniqueID ] <> b.[UniqueID ]
		AND a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortpolioNashville..NashvilleHouse a,
PortpolioNashville..NashvilleHouse b 
WHERE	a.ParcelID = b.ParcelID 
		AND a.[UniqueID ] <> b.[UniqueID ]



------------------------------------------------------

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLOMN (ADDRESS, CITY, STATE)
-- MISAHIN ALAMAT MEJADI BEBERAPA BAGIAN(ADDRESS, CITY DAN STATE)


SELECT PropertyAddress
FROM PortpolioNashville..NashvilleHouse
--WHERE PropertyAddress IS NULL
--Order by ParcelID		


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS ADDRESS
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS ADDRESS
FROM PortpolioNashville..NashvilleHouse



ALTER TABLE NashvilleHouse
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHouse
ADD PropertiSplitCity NVARCHAR(255);

UPDATE NashvilleHouse
SET PropertiSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 


SELECT *
FROM PortpolioNashville..NashvilleHouse

SELECT OwnerAddress
FROM PortpolioNashville..NashvilleHouse


SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortpolioNashville..NashvilleHouse


ALTER TABLE NashvilleHouse
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE NashvilleHouse
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 


ALTER TABLE NashvilleHouse
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


------------------------------------------------------

-- MERUBAH Y DAN N MENJADI YES DAN NO IN 'SOLDASVACANT' FILED


SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortpolioNashville..NashvilleHouse
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortpolioNashville..NashvilleHouse


UPDATE NashvilleHouse
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

------------------------------------------------------
--REMOVE DUPLICATES


WITH Row_rumCTE AS(
SELECT *,
	ROW_NUMBER()OVER(
			PARTITION BY ParcelID,
						 PropertyAddress,
						 SaleDate,
						 SalePrice,
						 LegalReference
						 ORDER BY 
						 UniqueID
						 
	) RUM_NUM
FROM PortpolioNashville..NashvilleHouse
)

SELECT *
FROM Row_rumCTE
WHERE RUM_NUM >1
ORDER BY  PropertyAddress

SELECT*
FROM PortpolioNashville..NashvilleHouse

------------------------------------------------------

--DELETE UNUSED COLUMNS


SELECT*
FROM PortpolioNashville..NashvilleHouse

ALTER TABLE PortpolioNashville..NashvilleHouse
DROP COLUMN PropertyAddress, SaleDate,TaxDistrict,OwnerAddress
