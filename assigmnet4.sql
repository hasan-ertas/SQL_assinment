--Charlie's Chocolate Factory company produces chocolates. The following product information is stored: 
--product name, product ID, and quantity on hand. These chocolates are made up of many components. 
--Each component can be supplied by one or more suppliers. The following component information is kept: 
--component ID, name, description, quantity on hand, suppliers who supply them, when and how much they supplied, 
--and products in which they are used. 
--On the other hand following supplier information is stored: supplier ID, name, and activation status.

--Assumptions

--A supplier can exist without providing components.
--A component does not have to be associated with a supplier. It may already have been in the inventory.
--A component does not have to be associated with a product. Not all components are used in products.
--A product cannot exist without components. 

--Do the following exercises, using the data model.

    -- a) Create a database named "Manufacturer"

	CREATE DATABASE Manufactuer
    GO

	--Create Schemas

CREATE SCHEMA product
GO
CREATE SCHEMA supplier
GO
CREATE SCHEMA component
GO

   --  b) Create the tables in the database.
   CREATE TABLE [product].[product](
	[prod_id] INT PRIMARY KEY NOT NULL,
	[Prod_name] [nvarchar](50) NOT NULL,
	[quantity] INT NOT NULL,

);
     
	  CREATE TABLE [supplier].[supplier](
	[supp_id] INT PRIMARY KEY NOT NULL,
	[supp_name] [nvarchar](50) NOT NULL,
	[supp_location] [nvarchar](50) NOT NULL,
	[supp_country] [nvarchar](50) NOT NULL,
	[is_active] int NOT NULL,
); 
ALTER TABLE [supplier].[supplier]
ALTER COLUMN [is_active] BIT NOT NULL;
	  CREATE TABLE [Component].[Component](
	[comp_id] INT PRIMARY KEY NOT NULL,
	[comp_name] [nvarchar](50) NOT NULL,
	[description] [nvarchar](50) NOT NULL,
	[quantity_comp] [nvarchar](50) NOT NULL,



	 --c) Define table constraints.
	 CREATE TABLE [dbo].[prod_comp](
    [prod_id] INT NOT NULL,
    [comp_id] INT NOT NULL,
	
    CONSTRAINT PK_prod_comp PRIMARY KEY ([prod_id], [comp_id]),
    CONSTRAINT FK_prod_comp_product FOREIGN KEY ([prod_id]) REFERENCES [product].[product]([prod_id]),
    CONSTRAINT FK_prod_comp_component FOREIGN KEY ([comp_id]) REFERENCES [Component].[Component]([comp_id])
);
ALTER TABLE [dbo].[prod_comp]
ADD [quantity_comp] INT NOT NULL;

	 CREATE TABLE [dbo].[comp_supp](
    [comp_id] INT NOT NULL,
    [supp_id] INT NOT NULL,
	[order_date] DATE NOT NULL,
    [quantity] INT NOT NULL,
    CONSTRAINT PK_comp_supp PRIMARY KEY ([comp_id], [supp_id]),
    CONSTRAINT FK_comp_supp_component FOREIGN KEY ([comp_id]) REFERENCES [Component].[Component]([comp_id]),
    CONSTRAINT FK_comp_supp_supplier FOREIGN KEY ([supp_id]) REFERENCES [supplier].[supplier]([supp_id])
);
