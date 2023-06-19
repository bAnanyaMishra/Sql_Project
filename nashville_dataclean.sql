/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
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
  FROM [portfolio_project].[dbo].[NashvilleHousing]

  select * 
  from portfolio_project.dbo.NashvilleHousing;

  --change  date formats
  select SaleDate,convert(Date,SaleDate )
  from portfolio_project.dbo.NashvilleHousing;

  update portfolio_project.dbo.NashvilleHousing
  set DateConv = convert(Date,SaleDate,105 )

  alter table portfolio_project.dbo.NashvilleHousing
  add DateConv Date;

  -- Address changes
  select * 
  from portfolio_project.dbo.NashvilleHousing;

  select n1.UniqueID,n1.ParcelID,n1.PropertyAddress,n2.UniqueID,n2.ParcelID,n2.PropertyAddress, ISNULL(n2.PropertyAddress,n1.PropertyAddress)  --isNULL to check if n2 is null populate n1value
  from portfolio_project.dbo.NashvilleHousing n1
  join portfolio_project.dbo.NashvilleHousing n2 on n1.ParcelID=n2.ParcelID
  where n1.UniqueID != n2.[UniqueID ]
and n2.PropertyAddress is NULL;

update n2
set PropertyAddress = ISNULL(n2.PropertyAddress,n1.PropertyAddress)
from portfolio_project.dbo.NashvilleHousing n1
  join portfolio_project.dbo.NashvilleHousing n2 on n1.ParcelID=n2.ParcelID
  where n1.UniqueID != n2.[UniqueID ]
and n2.PropertyAddress is NULL;


--Breaking address into address,city,state

 select *
  from portfolio_project.dbo.NashvilleHousing;

  select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
  from portfolio_project.dbo.NashvilleHousing;

  alter table portfolio_project.dbo.NashvilleHousing
  add SplitAddress varchar(255),
  SplitCity varchar(255);

  Update portfolio_project.dbo.NashvilleHousing
  set SplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

  Update portfolio_project.dbo.NashvilleHousing
  set SplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress));

  -- owner address change
  select *
  from portfolio_project.dbo.NashvilleHousing;


  select OwnerAddress,PARSENAME(replace (OwnerAddress,',','.'),3),PARSENAME(replace (OwnerAddress,',','.'),2),PARSENAME(replace (OwnerAddress,',','.'),1)
  from portfolio_project.dbo.NashvilleHousing;

  alter table portfolio_project.dbo.NashvilleHousing
  add OwnerSplitAddress varchar(255),
  OwnerSplitCity varchar(255),
  OwnerSplitState nvarchar(255);

   Update portfolio_project.dbo.NashvilleHousing
  set OwnerSplitCity = PARSENAME(replace (OwnerAddress,',','.'),2);

     Update portfolio_project.dbo.NashvilleHousing
  set OwnerSplitAddress = PARSENAME(replace (OwnerAddress,',','.'),3);

     Update portfolio_project.dbo.NashvilleHousing
  set OwnerSplitState = PARSENAME(replace (OwnerAddress,',','.'),1);

  -- Yes and NO changes 
  select distinct SoldAsVacant, count(SoldAsVacant)
  from portfolio_project.dbo.NashvilleHousing
  group by SoldAsVacant;

  select UniqueID,SoldAsVacant from portfolio_project.dbo.NashvilleHousing where SoldAsVacant like 'n';
  select [UniqueID ],SoldAsVacant,
  case 
  when SoldAsVacant ='N' then 'No' 
   when SoldAsVacant ='Y' then 'Yes'
   else SoldAsVacant
   end
  from portfolio_project.dbo.NashvilleHousing
  order by [UniqueID ]

  update portfolio_project.dbo.NashvilleHousing
  set SoldAsVacant = 
  case 
  when SoldAsVacant ='N' then 'No' 
   when SoldAsVacant ='Y' then 'Yes'
   else SoldAsVacant
   end

 -- Remove duplicates

 select * 
 from portfolio_project.dbo.NashvilleHousing;

 select OwnerName , count(OwnerName) from
 portfolio_project.dbo.NashvilleHousing
 group by [OwnerName] having count(OwnerName) > 1;

 select *,newrow
 from
 (select *,
 ROW_NUMBER() over(partition by
 ParcelID,
 SalePrice,
 SaleDate,
 LegalReference
 order by 
 UniqueID) as newrow
 from portfolio_project.dbo.NashvilleHousing
) t
 where t.newrow>1
 order by UniqueID;

 --or
 with cte1 as
 (select *,
 ROW_NUMBER() over(partition by
 ParcelID,
 SalePrice,
 SaleDate,
 LegalReference
 order by 
 UniqueID) as newrow
 from portfolio_project.dbo.NashvilleHousing)

delete from cte1 where newrow> 1 ;
--order by PropertyAddress;

--drop unused columns

alter table portfolio_project.dbo.NashvilleHousing
drop column OwnerAddress,PropertyAddress,SaleDate