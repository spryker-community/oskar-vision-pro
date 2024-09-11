# Oskar Vision Pro B2C Demo Shop

## Description

This is a clone from the Spryker B2C Demo Shop repository.
It has been altered to include paths to ProductModel data in Glue Requests for abstract products.
Products need to be created and ProductModels as usdz files need to be placed in the public folder of Yves.
Then
>src/Pyz/Glue/ProductsRestApi/Processor/AbstractProducts/AbstractProductsReader.php

needs to be altered to map the usdz files to the abstract products.

## Installation

Normal Spryker B2C installation should be followed.
