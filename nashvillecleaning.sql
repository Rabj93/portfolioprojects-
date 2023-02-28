SET sql_mode = 'IGNORE_SPACE';
set sql_mode = 'ANSI';
use project;
-- cleaning data in SQl Queries 

select * 
from project.nashville;
----------------------------------------------------------------
-- standerize data format

SELECT SaleDate,DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%y/%m/%d') -- AS ConvertedSaleDate 
FROM project.nashville;

update nashville
set SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%y/%m/%d');

alter table nashville 
add SaleDateConverted Date;

update nashville
set SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%y/%m/%d');
    

	
 -------------------------------------------------------------------  
-- populate property Address data 

select * 
from project.nashville
-- where propertyaddress = ' '
order by ParcelID;


select a.ParcelID, a.PropertyAddress, b.ParcelID,'b.PropertyAdress', ifnull(a.PropertyAddress,'b.PropertyAdress')
from project.nashville a
join project.nashville	b
	on a.ParcelID = b.ParcelID
    and a.`UniqueID` <> b.`UniqueID`
 where a.PropertyAddress is null;

UPDATE project.nashville a
        JOIN
    project.nashville b ON a.ParcelID = b.ParcelID
        AND a.`UniqueID` <> b.`UniqueID` 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;
    
    
-------------------------------------------------------------------------------------------------

-- breaking out Address into individual columns (address, city, state) 

select PropertyAddress 
from project.nashville;
-- where propertyaddress = ' '
-- order by ParcelID;


select 
substring(propertyaddress, 1, locate(',', propertyaddress) -1) as address,
substring(propertyaddress, locate(',', propertyaddress) + 1, length(propertyaddress)) as address
from project.nashville;

alter table nashville 
add propertysplitaddress Varchar(255);

update nashville
set propertysplitaddress = substring(propertyaddress, 1, locate(',', propertyaddress) -1);

alter table nashville 
add propertysplitcity Varchar(255);

update nashville
set propertysplitcity = substring(propertyaddress, locate(',', propertyaddress) + 1, length(propertyaddress));

select *
from project.nashville;


select OwnerAddress
from project.nashville;


select 
parsename(replace(OwnerAddress, ',', '.'),3),
parsename(replace(OwnerAddress, ',', '.'),2),
parsename(replace(OwnerAddress, ',', '.'),1)
from project.nashville;

alter table nashville 
add ownersplitaddress Varchar(255);

update nashville
set ownersplitaddress = parsename(replace(OwnerAddress, ',', '.'),3);

alter table nashville 
add ownersplitcity Varchar(255);

update nashville
set ownersplitcity = parsename(replace(OwnerAddress, ',', '.'),2);

alter table nashville 
add ownerstate Varchar(255);

update nashville
set ownersplitaddress = parsename(replace(OwnerAddress, ',', '.'),1);

----------------------------------------------------------------------------------------------------

-- change Y and N to yes and no in 'sold as Vacant' field 

select distinct(soldAsVacant), count(soldAsVacant)
from project.nashville
group by soldAsVacant
order by 2;
select soldAsVacant, 
case when soldAsVacant = 'y' then 'yes'
	 when soldAsVacant = 'n' then 'no'
     else soldAsVacant
     end
from project.nashville;

update nashville
set soldasvacant = case when soldAsVacant = 'y' then 'yes'
	 when soldAsVacant = 'n' then 'no'
     else soldAsVacant
     end;
     
-------------------------------------------------------------------------------------------------

-- remove duplicates 
with RowNUMCTE as(
select *, 
row_number() over(
partition by ParcelID,
			 PropertyAddress,
             SalePrice,
             SaleDate,
             LegalReference
             order by
				uniqueid) row_num
from project.nashville
order by ParcelID)

Delete 
from project.nashville
 where 'RowNUMCTE' > 1;
 -- order by PropertyAddress;
 
 


------------------------------------------------------

-- delete unused columns, not deleting columns not good practice but wrote the query out. 

select *
from project.nashville;

alter TABLE project.nashville
DROP column owneraddress, TaxDistrict, propertyaddres, Saledate



 
 


  
  