<?php

namespace Pyz\Glue\ProductsRestApi;

use Pyz\Glue\ProductsRestApi\Processor\AbstractProducts\AbstractProductsReader;
use Spryker\Glue\ProductsRestApi\Processor\AbstractProducts\AbstractProductsReaderInterface;
use Spryker\Glue\ProductsRestApi\ProductsRestApiFactory as SprykerProductsRestApiFactory;

class ProductsRestApiFactory extends SprykerProductsRestApiFactory
{
    /**
     * @return \Spryker\Glue\ProductsRestApi\Processor\AbstractProducts\AbstractProductsReaderInterface
     */
    public function createAbstractProductsReader(): AbstractProductsReaderInterface
    {
        return new AbstractProductsReader(
            $this->getProductStorageClient(),
            $this->getResourceBuilder(),
            $this->createAbstractProductsResourceMapper(),
            $this->createConcreteProductsReader(),
            $this->getConfig(),
            $this->createAbstractProductAttributeTranslationExpander(),
            $this->getAbstractProductResourceExpanderPlugins(),
        );
    }
}
