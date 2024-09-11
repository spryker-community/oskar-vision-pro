<?php

namespace Pyz\Glue\ProductsRestApi\Controller;

use Spryker\Glue\GlueApplication\Rest\JsonApi\RestResponseInterface;
use Spryker\Glue\GlueApplication\Rest\Request\Data\RestRequestInterface;
use Spryker\Glue\ProductsRestApi\Controller\AbstractProductsResourceController as SprykerAbstractProductsResourceController;

/**
 * @method \Pyz\Glue\ProductsRestApi\ProductsRestApiFactory getFactory()
 */
class AbstractProductsResourceController extends SprykerAbstractProductsResourceController
{
    /**
     * @Glue({
     *     "getResourceById": {
     *          "summary": [
     *              "Retrieves product abstract by id."
     *          ],
     *          "parameters": [{
     *              "ref": "acceptLanguage"
     *          }],
     *          "responses": {
     *              "400": "Abstract product id is not specified.",
     *              "404": "Abstract product not found."
     *          }
     *     }
     * })
     *
     * @param \Spryker\Glue\GlueApplication\Rest\Request\Data\RestRequestInterface $restRequest
     *
     * @return \Spryker\Glue\GlueApplication\Rest\JsonApi\RestResponseInterface
     */
    public function getAction(RestRequestInterface $restRequest): RestResponseInterface
    {
        return $this->getFactory()
            ->createAbstractProductsReader()
            ->getProductAbstractStorageData($restRequest);
    }
}
