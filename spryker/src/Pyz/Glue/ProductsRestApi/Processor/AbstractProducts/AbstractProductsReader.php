<?php

namespace Pyz\Glue\ProductsRestApi\Processor\AbstractProducts;

use Spryker\Glue\GlueApplication\Rest\JsonApi\RestResourceInterface;
use Spryker\Glue\GlueApplication\Rest\Request\Data\RestRequestInterface;
use Spryker\Glue\ProductsRestApi\Processor\AbstractProducts\AbstractProductsReader as SprykerAbstractProductsReader;

class AbstractProductsReader extends SprykerAbstractProductsReader
{
    public const PRODUCT_MODEL_DATA = [
        216 => '/assets/models/oskar.usdz',
        998 => '\Pyz\Shared\ProductModel\Models\2.stl',
        997 => '\Pyz\Shared\ProductModel\Models\3.stl',
        996 => '\Pyz\Shared\ProductModel\Models\4.stl',
    ];
    public const PREFIX = 'http://yves.de.spryker.local';

    /**
     * @param string $sku
     * @param \Spryker\Glue\GlueApplication\Rest\Request\Data\RestRequestInterface $restRequest
     *
     * @return \Spryker\Glue\GlueApplication\Rest\JsonApi\RestResourceInterface|null
     */
    public function findProductAbstractBySku(string $sku, RestRequestInterface $restRequest): ?RestResourceInterface
    {
        $localeName = $restRequest->getMetadata()->getLocale();
        $productAbstractData = $this->productStorageClient
            ->findProductAbstractStorageDataByMapping(
                static::PRODUCT_ABSTRACT_MAPPING_TYPE,
                $sku,
                $localeName,
            );

        $productAbstractData = $this->appendProductModelData($productAbstractData);

        if (!$productAbstractData) {
            return null;
        }

        return $this->createRestResourceFromAbstractProductStorageData($productAbstractData, $localeName);
    }

    /**
     * @param int $idProductAbstract
     * @param \Spryker\Glue\GlueApplication\Rest\Request\Data\RestRequestInterface $restRequest
     *
     * @return \Spryker\Glue\GlueApplication\Rest\JsonApi\RestResourceInterface|null
     */
    public function findProductAbstractById(int $idProductAbstract, RestRequestInterface $restRequest): ?RestResourceInterface
    {
        $localeName = $restRequest->getMetadata()->getLocale();
        $productAbstractData = $this->productStorageClient
            ->findProductAbstractStorageData($idProductAbstract, $localeName);

        $productAbstractData = $this->appendProductModelData($productAbstractData);

        if (!$productAbstractData) {
            return null;
        }

        return $this->createRestResourceFromAbstractProductStorageData($productAbstractData, $localeName);
    }

    /**
     * @param array|null $productAbstractData
     *
     * @return array|void
     */
    protected function appendProductModelData(?array $productAbstractData): ?array
    {
        if (!$productAbstractData) {
            return null;
        }

        $idProductAbstract = $productAbstractData['id_product_abstract'];

        if (isset(static::PRODUCT_MODEL_DATA[$idProductAbstract])) {
            $productAbstractData['product_model'] =
                static::PREFIX . static::PRODUCT_MODEL_DATA[$idProductAbstract];
        }

        return $productAbstractData;
    }
}
