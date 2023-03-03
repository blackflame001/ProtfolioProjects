/*

	Cleaning Data In SQL 

*/

Select * 
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing


Update NashvilleHousing  
Set SaleDate = CONVERT(Date,SaleDate)

-- If above query does not work proper

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing 
Set SaleDateConverted = CONVERT(Date,SaleDate)



-----------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID



Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, 
		ISNULL(A.PropertyAddress,B.PropertyAddress)
From PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
		ON A.ParcelID = B.ParcelID 
		AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is NULL

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
		ON A.ParcelID = B.ParcelID 
		AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is NULL



-----------------------------------------------------------------------------------------------------------------

-- Dividing Adress into Individual Columns (Address, City, Sate,)


-- Splitting PropertyAddress using SUBSTRING function

Select PropertyAddress
From PortfolioProject..NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City 
From PortfolioProject..NashvilleHousing

-- Property Address Column Creation and Updating Column 
Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


-- Property City Column Creation and Updating Column
Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing 
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

Select * 
From PortfolioProject..NashvilleHousing



-- Dividing OwnerAddress into Individual Columns (Address, City, Sate,)
-- Using Parsename and  it work with '.' so converted ',' to '.' with REPLACE

Select OwnerAddress 
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),	
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From PortfolioProject..NashvilleHousing

-- Adding OwnerSplitAddress, OwnerSplitCity and OwnerSplitState Column
Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Alter Table NashvilleHousing
add OwnerSplitSate Nvarchar(255);

Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

-- Updating OwnerSplitAddress, OwnerSplitCity and OwnerSplitState Column
Update NashvilleHousing 
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)

Update NashvilleHousing 
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Update NashvilleHousing 
Set OwnerSplitSate = PARSENAME(Replace(OwnerAddress,',','.'),1)


Select * 
From PortfolioProject..NashvilleHousing



-----------------------------------------------------------------------------------------------------------------

-- Replacing "Y" and "N" to Yes and No in Column/Field "Sold As Vacant"


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-----------------------------------------------------------------------------------------------------------------

-- Removing Duplicates using CTE and ROW_NUMBER function


Select * 
From PortfolioProject..NashvilleHousing

WITH Row_Num_CTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID) row_num
From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete
From Row_Num_CTE
where row_num >1
/*
Select *
From Row_Num_CTE
where row_num >1
order by PropertyAddress
*/



-----------------------------------------------------------------------------------------------------------------

-- Removing Unused Columns
-- Caution Do not delete data or columns from raw data table


Alter Table PortfolioProject..NashvilleHousing 
Drop Column PropertyAddress, OwnerAddress, TaxDistrict
