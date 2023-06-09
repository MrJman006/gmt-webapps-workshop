import {HTTP_STATUS_CODES} from "../modules/http-status-codes.js";
import {hasAllowedOrigin, generateForbiddenOriginResponse} from "../modules/http-origin-access-control.js";
import {generateUnsupportedHttpMethodResponse} from "../modules/unsupported-http-methods.js";

/**
* The name of this API endpoint.
*
* @type {String}
*/
let API_NAME = "product-list";

/**
* Access control headers for the token API.
*
* @type {Headers}
*/
let API_HEADERS = new Headers({
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
    'Access-Control-Allow-Headers': '*'
});

/**
* Handles GET requests.
*
* @param {Request} request - A request object.
*
* @return {Promise<Response>} - A response object.
*/
async function handleGET(request)
{
    let response;

    //
    // Return the product list.
    //

    let data = await STORAGE.get("productList");

    let responseBody = data;

    response = new Response(
        responseBody,
        {
            status: HTTP_STATUS_CODES.OK,
            headers: API_HEADERS
        }
    );

    return response;
}

/**
* Handles fetch requests.
*
* @param {Request} request - A request object.
*
* @return {Promise<Response>} - A response object.
*/
async function handleRequest(request)
{
    let response;

    //
    // Only allow whitelisted origins.
    //

    let originAllowed = hasAllowedOrigin(request);

    if(!originAllowed)
    {
        response = generateForbiddenOriginResponse(API_HEADERS);
        return response;
    }

    //
    // Respond to HEAD and OPTIONS requests.
    //

    if(request.method === "HEAD" || request.method === "OPTIONS")
    {
        response = new Response(
            "Ok",
            {
                status: HTTP_STATUS_CODES.OK,
                headers: API_HEADERS
            }
        );

        return response;
    }

    //
    // Respond to GET requests.
    //

    if(request.method === "GET")
    {
        response = await handleGET(request);
        return response;
    }

    //
    // Unsupported methods.
    //

    response = generateUnsupportedHttpMethodResponse(API_NAME, API_HEADERS);
    return response;
}

// Listen for API calls.
addEventListener(
    'fetch',
    function(event)
    {
        let request = event.request;
        let promise = handleRequest(request);
        event.respondWith(promise);
    }
);
