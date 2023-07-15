/*

Nashville housing data cleaning using SQL queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

--Here we want to standardize date format in SaleDate column
--Using (CONVERT) to convert SaleDate type from datetime time type to date type
--Using (ALTER TABLE) to make changes on the table to add new column
--Using (UPDATE SET) to insert the new formatted date data into the new added column

SELECT SaleDate, New_SaleDate, CONVERT(DATE, SaleDate) AS New
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD New_SaleDate DATE;

UPDATE NashvilleHousing
SET New_SaleDate = CONVERT(DATE, SaleDate)

--Here we want to populate property address data
--We find that there are rows with the same ParcelID, different other data but one of it with address and other without address (NULL) so we want to populate property address to replace these NULLs
--Using (self JOIN) to look at the same parcel ID but different unique ID and update the property address with NULL values
--USING (ISNULL) to check whether the first selected value in this query is null then add the second value to generated column        ISNULL(first value,second value)
SELECT ParcelID,PropertyAddress
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
ORDER BY a.ParcelID

--Now use (UPDATE SET) to put the values in the generated column from ISNULL in a.PropertyAddress

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

--We want to Break out PropertyAddress into individual 2 columns (Address, City)
--We will use (SUBSTRING) to make this                          SUBSTRING(Expression/column containing string, location to start substring, location to end substring) 

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) AS Address,    --We here used (CHARINDEX) to get the index of the (,) to know where to stop the string
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City   --LEN() gives the total number of characters in the string so it gives the last index
FROM PortfolioProject..NashvilleHousing

--Now it is time to change our table by adding these new columns and updating their values

ALTER TABLE NashvilleHousing
ADD New_PropertAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET New_PropertAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--We want to make the same with OwnerAddress to break it out to 3 individual columns (Address, City, State)
--We can use (SUBSTRING) like we used for PropertyAddress but there is another way that we gonna use this time which is (PARSENAME)         

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Adress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM PortfolioProject..NashvilleHousing
WHERE OwnerAddress IS NOT NULL

--Now it is time to change our table by adding these new columns and updating their values

ALTER TABLE NashvilleHousing
ADD New_OwnerAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET New_OwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD Owner_City NVARCHAR(255);

UPDATE NashvilleHousing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD Owner_State NVARCHAR(255);

UPDATE NashvilleHousing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in SoldAsVacant column

SELECT SoldAsVacant, COUNT(SoldAsVacant) AS Count
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count




SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END AS Update_SoldAsVacant
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
     WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

--Removing Duplicates
--Use (CTE) to not delete the original data in the database

WITH RowNumCTE
AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) AS Row_Num
FROM PortfolioProject..NashvilleHousing
)
--DELETE
--FROM RowNumCTE                                  We use these delete lines to remove all duplicated rows then commented it to not use again while checking our CTE
--WHERE Row_Num>1
SELECT *
FROM RowNumCTE
WHERE Row_Num>1
ORDER BY PropertyAddress

--Delete unused columns (SaleDate, PropertyAddress, OwnerAddress)

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate





