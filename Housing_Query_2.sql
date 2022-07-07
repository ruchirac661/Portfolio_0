--Data Cleaning in SQL server

Select *
From Portfolio_1.dbo.Housing


--Standardize Sale date

Select CONVERT(date,SaleDate)
From Portfolio_1.dbo.Housing

--Can also use
--Update Portfolio_1.dbo.Housing
--SET SaleDate = CONVERT(date, SaleDate)


Alter Table Portfolio_1..Housing
ADD SaleDateConverted Date

Update Portfolio_1..Housing
Set SaleDateConverted = CONVERT(date,SaleDate)


Select SaleDateConverted, CONVERT(date,SaleDate)
From Portfolio_1.dbo.Housing


--Populate property address

Select *
From Portfolio_1.dbo.Housing
order by ParcelID


Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From Portfolio_1..Housing as A
Join Portfolio_1..Housing as B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is  null


Update A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From Portfolio_1..Housing as A
Join Portfolio_1..Housing as B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is  null


--Verifying the Update
Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
From Portfolio_1..Housing as A
Join Portfolio_1..Housing as B
	On A.ParcelID = B.ParcelID
	And A.[UniqueID ] <> B.[UniqueID ]

	--Since no null values


--Breaking Address into different columns
Select PropertyAddress
From Portfolio_1.dbo.Housing
order by ParcelID


Select 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
	,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress)) as City
	--CHARINDEX(',', PropertyAddress) returns the position of the comma, whcih can be replaced directly in a fn
From Portfolio_1.dbo.Housing


Alter Table Portfolio_1..Housing
ADD SplitAddress varchar(255)

Update Portfolio_1..Housing
Set SplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


Alter Table Portfolio_1..Housing
ADD SplitCity varchar(255)

Update Portfolio_1..Housing
Set SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , LEN(PropertyAddress))

--Verification

Select *
From Portfolio_1.dbo.Housing
Order by ParcelID

--For the OwnerAddress next
--Using PARSENAME


Select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Portfolio_1.dbo.Housing


Alter Table Portfolio_1..Housing
ADD OwnersplitAddress varchar(255)

Update Portfolio_1..Housing
Set OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table Portfolio_1..Housing
ADD OwnerCity varchar(255)

Update Portfolio_1..Housing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter Table Portfolio_1..Housing
ADD OwnerState varchar(255)

Update Portfolio_1..Housing
Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_1.dbo.Housing
Group by SoldAsVacant

--Changing Y and N to Yes and No for SoldAsVacant


Select SoldAsVacant
,CASE when SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From Portfolio_1.dbo.Housing


Update Portfolio_1..Housing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
			when SoldAsVacant = 'N' Then 'No'
			Else SoldAsVacant
			End

	--Verifying.....
	Select Distinct(SoldAsVacant), Count(SoldAsVacant)
	From Portfolio_1.dbo.Housing
	Group by SoldAsVacant


--Deleting unused columns

Select *
From Portfolio_1.dbo.Housing

ALTER TABLE Portfolio_1.dbo.Housing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict
