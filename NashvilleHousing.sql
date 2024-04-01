SELECT * FROM nashvillehousing;
SET SQL_SAFE_UPDATES = 0;

# Eliminating spaces from column names
ALTER TABLE nashvillehousing
RENAME COLUMN `Unique ID` TO UniqueID;

ALTER TABLE nashvillehousing
RENAME COLUMN `Parcel ID` TO ParcelID;

#Verifying the data type of SaleDate

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Final'
AND
TABLE_NAME = 'nashvillehousing'
AND
COLUMN_NAME = 'SaleDate';

#Adding a column named "ConvertedSaleDate" with the SaleDate converted to a date format

ALTER TABLE nashvillehousing
ADD COLUMN Converted_Date DATE;

UPDATE nashvillehousing
SET Converted_Date=STR_TO_DATE(SaleDate, '%M %d, %Y');

# Setting empy rows to NULL in PropertyAddress
UPDATE nashvillehousing SET PropertyAddress =  NULLIF(PropertyAddress,'');

SELECT *
FROM nashvillehousing
WHERE PropertyAddress is NULL;

# Updating the nashvillehousing table to populate missing data in the "PropertyAddress" 

UPDATE nashvillehousing AS a
JOIN nashvillehousing AS b
ON a.ParcelID = b.ParcelID 
AND a.UniqueID <> b.UniqueID 
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress) 
WHERE a.PropertyAddress IS NULL;


#Using Substring to seperate adress from city in a PropertyAddress column 

ALTER TABLE nashvillehousing
ADD COLUMN PAdress varchar(70);

UPDATE nashvillehousing
SET PAdress=SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1);

ALTER TABLE nashvillehousing
ADD COLUMN PropertyCity varchar(70);

UPDATE nashvillehousing
SET PropertyCity=SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+2);


#Seperate adress from city and state in a OwnerAdress column 
ALTER TABLE nashvillehousing
ADD COLUMN OwnerAddressStreet varchar(70);
ALTER TABLE nashvillehousing
ADD COLUMN OwnerAddressCity varchar(70);
ALTER TABLE nashvillehousing
ADD COLUMN OwnerAddressState varchar(20);

UPDATE nashvillehousing 
SET OwnerAddressStreet=SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1);

UPDATE nashvillehousing 
SET OwnerAddressCity= SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE nashvillehousing 
SET  OwnerAddressState=SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

#Using Case statment to update SoldAsVacant 1 =Yes , 0=No 

UPDATE nashvillehousing 
SET SoldAsVacant=
CASE WHEN SoldAsVacant='No' THEN 0 
     WHEN SoldAsVacant='N' THEN 0 
     WHEN SoldAsVacant='Yes' THEN 1
     WHEN SoldAsVacant='Y' THEN 1
     ELSE NULL
     END;
     
#Usint CTE to identify duplicate rows in the data
 WITH Row_CTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
FROM nashvillehousing)
SELECT *
FROM Row_CTE
WHERE row_num>1;

# Create a view with out duplicates 
CREATE VIEW nashvillehousing_view AS 
 WITH Row_CTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) AS row_num
FROM nashvillehousing) 
SELECT * FROM Row_CTE WHERE row_num=1;










