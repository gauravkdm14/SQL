select *
from PortfolioProject..data;

--Standardize Date Format

select saledateconverted, convert(date, SaleDate)
from PortfolioProject..data;

update data
set SaleDate = convert(date, SaleDate)

alter table data
add saledateconverted date;

update data
set saledateconverted = convert(date, SaleDate)

--populate property address data

select *
from PortfolioProject..data
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..data a
join PortfolioProject..data b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..data a
join PortfolioProject..data b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking down the address

select PropertyAddress
from PortfolioProject..data
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as address
from PortfolioProject..data

alter table data
add PropertySplitAddress nvarchar(255);

update data
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

alter table data
add PropertySplitCity nvarchar(255);

update data
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

select *
from PortfolioProject..data






select OwnerAddress
from PortfolioProject..data

select
parsename(replace(OwnerAddress, ',', '.') , 3),
parsename(replace(OwnerAddress, ',', '.') , 2),
parsename(replace(OwnerAddress, ',', '.') , 1)
from PortfolioProject..data

alter table data
add OwnerSplitAddress nvarchar(255);

update data
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.') , 3)

alter table data
add OwnerSplitCity nvarchar(255);

update data
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.') , 2)

alter table data
add OwnerSplitState nvarchar(255);

update data
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.') , 1)

select *
from PortfolioProject..data



--change Y and N to yes and no in "solid as vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..data
group by SoldAsVacant
order by 2


select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..data

update data
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end





