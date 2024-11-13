

SELECT *
FROM housing_data;

--- Check the totalvalue of the land and building
SELECT TotalValue, (LandValue + BuildingValue) As NewTotalValue
FROM housing_data;

UPDATE housing_data
SET TotalValue = (LandValue + BuildingValue);

---Reduce the decimal in Acreage column
SELECT Acreage, CAST(Acreage AS DECIMAL(10,2))  As NewAcreage
FROM housing_data;

UPDATE housing_data
SET Acreage = CAST(Acreage AS DECIMAL(10,2));

---- Populate property address data

SELECT *
FROM housing_data
ORDER BY ParcelID;

SELECT HD1.ParcelID, HD1.PropertyAddress, HD2.ParcelID, HD2.PropertyAddress, ISNULL(HD1.PropertyAddress, HD2.PropertyAddress)
FROM housing_data HD1
JOIN housing_data HD2
	ON HD1.ParcelID = HD2.ParcelID
	AND HD1.UniqueID <> HD2.UniqueID
WHERE HD1.PropertyAddress IS NULL;

UPDATE HD1
SET PropertyAddress = ISNULL(HD1.PropertyAddress, HD2.PropertyAddress)
FROM housing_data HD1
JOIN housing_data HD2
	ON HD1.ParcelID = HD2.ParcelID
	AND HD1.UniqueID <> HD2.UniqueID
WHERE HD1.PropertyAddress IS NULL;

SELECT *
FROM housing_data
WHERE PropertyAddress IS NULL;

---Breaking out property address into individual columns (address, city, and state)
SELECT PropertyAddress
FROM housing_data;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM housing_data;

ALTER TABLE housing_data
ADD PropertySplitAddress NVARCHAR(255);

UPDATE housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE housing_data
ADD PropertySplitCity NVARCHAR(255);

UPDATE housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM housing_data;

SELECT OwnerAddress
FROM housing_data;

---Spliting owner address into individual columns (address, city, and state)

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress,',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress,',', '.') , 1)
FROM housing_data;

ALTER TABLE housing_data
ADD NewOwnerAddress NVARCHAR(255);

UPDATE housing_data
SET NewOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',', '.') , 3);

ALTER TABLE housing_data
ADD NewOwnerCity NVARCHAR(255);

UPDATE housing_data
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2);

ALTER TABLE housing_data
ADD NewOwnerState NVARCHAR(255);

UPDATE housing_data
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1);


---Change the value in soldasvacant column to Yes and No
SELECT DISTINCT (SoldAsVacant)
FROM housing_data;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 0 THEN 'No'
		WHEN SoldAsVacant = 1 THEN 'Yes'
		END
FROM housing_data;

ALTER TABLE housing_data
ADD NewSoldAsVacant NVARCHAR(255);

UPDATE housing_data
SET NewSoldAsVacant = CASE WHEN SoldAsVacant = 0 THEN 'No'
						WHEN SoldAsVacant = 1 THEN 'Yes'
						END;

---remove duplicate

SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM housing_data
ORDER BY ParcelID;

WITH row_numCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM housing_data)
SELECT *
FROM row_numCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH row_numCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM housing_data)
DELETE 
FROM row_numCTE
WHERE row_num > 1;


--- Delete unused columns

SELECT *
FROM housing_data;

ALTER TABLE housing_data
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict