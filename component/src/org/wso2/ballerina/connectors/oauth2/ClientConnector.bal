package org.wso2.ballerina.connectors.oauth2;

import ballerina.net.http;

@Description { value:"OAuth2 client connector"}
@Param { value:"baseUrl: The endpoint base url"}
@Param { value:"accessToken: The access token of the account"}
@Param { value:"clientId: The client Id of the account"}
@Param { value:"clientSecret: The client secret of the account"}
@Param { value:"refreshToken: The refresh token of the account"}
@Param { value:"refreshTokenEP: The refresh token endpoint url"}
public connector ClientConnector (string baseUrl, string accessToken, string clientId, string clientSecret,
                                  string refreshToken, string refreshTokenEP, string refreshTokenPath) {

    endpoint<http:HttpClient> httpConnectorEP {
        create http:HttpClient(baseUrl, {});
    }

    string accessTokenValue;
    http:HttpConnectorError e;

    @Description { value:"Get with OAuth2 authentication"}
    @Param { value:"path: The endpoint path"}
    @Param { value:"request: The request of the method"}
    @Return { value:"response object"}
    @Return { value:"Error occured during HTTP client invocation." }
    action get (string path, http:Request request) (http:Response, http:HttpConnectorError) {
        http:Response response = {};

        accessTokenValue = constructAuthHeader (request, accessTokenValue, accessToken);
        response, e = httpConnectorEP.get (path, request);

        if ((response.getStatusCode() == 401) && (refreshToken != "" || refreshToken != "null")) {
            request = {};
            accessTokenValue = getAccessTokenFromRefreshToken(request, accessToken, clientId, clientSecret, refreshToken,
                                                              refreshTokenEP, refreshTokenPath);
            response, e = httpConnectorEP.get (path, request);
        }

        return response, e;
    }

    @Description { value:"Post with OAuth2 authentication"}
    @Param { value:"path: The endpoint path"}
    @Param { value:"request: The request of the method"}
    @Return { value:"response object"}
    @Return { value:"Error occured during HTTP client invocation." }
    action post (string path, http:Request originalReq) (http:Response, http:HttpConnectorError) {
        http:Response response = {};
        json incomingReq = originalReq.getJsonPayload();
        http:Request request = {};
        request.setJsonPayload(incomingReq);

        accessTokenValue = constructAuthHeader (request, accessTokenValue, accessToken);
        response, e = httpConnectorEP.post (path, request);

        if ((response.getStatusCode() == 401) && (refreshToken != "" || refreshToken != "null")) {
            accessTokenValue = getAccessTokenFromRefreshToken(request, accessToken, clientId, clientSecret, refreshToken,
                                                              refreshTokenEP, refreshTokenPath);

            response, e = httpConnectorEP.post (path, request);
        }

        return response, e;
    }

    @Description { value:"Put with OAuth2 authentication"}
    @Param { value:"path: The endpoint path"}
    @Param { value:"request: The request of the method"}
    @Return { value:"response object"}
    @Return { value:"Error occured during HTTP client invocation." }
    action put (string path, http:Request request) (http:Response, http:HttpConnectorError) {

        http:Response response = {};

        accessTokenValue = constructAuthHeader (request, accessTokenValue, accessToken);
        response, e = httpConnectorEP.put (path, request);

        if ((response.getStatusCode() == 401) && (refreshToken != "" || refreshToken != "null")) {
            request = {};
            accessTokenValue = getAccessTokenFromRefreshToken(request, accessToken, clientId, clientSecret, refreshToken,
                                                              refreshTokenEP, refreshTokenPath);
            response, e = httpConnectorEP.put (path, request);
        }

        return response, e;
    }

    @Description { value:"Delete with OAuth2 authentication"}
    @Param { value:"path: The endpoint path"}
    @Param { value:"request: The request of the method"}
    @Return { value:"response object"}
    @Return { value:"Error occured during HTTP client invocation." }
    action delete (string path, http:Request request) (http:Response, http:HttpConnectorError) {

        http:Response response = {};

        accessTokenValue = constructAuthHeader (request, accessTokenValue, accessToken);
        response, e = httpConnectorEP.delete (path, request);

        if ((response.getStatusCode() == 401) && (refreshToken != "" || refreshToken != "null")) {
            request = {};
            accessTokenValue = getAccessTokenFromRefreshToken(request, accessToken, clientId, clientSecret, refreshToken,
                                                              refreshTokenEP, refreshTokenPath);
            response, e = httpConnectorEP.delete (path, request);
        }

        return response, e;
    }

    @Description { value:"Patch with OAuth2 authentication"}
    @Param { value:"path: The endpoint path"}
    @Param { value:"request: The request of the method"}
    @Return { value:"response object"}
    @Return { value:"Error occured during HTTP client invocation." }
    action patch (string path, http:Request request) (http:Response, http:HttpConnectorError) {

        http:Response response = {};

        accessTokenValue = constructAuthHeader (request, accessTokenValue, accessToken);
        response, e = httpConnectorEP.patch (path, request);

        if ((response.getStatusCode() == 401) && (refreshToken != "" || refreshToken != "null")) {
            request = {};
            accessTokenValue = getAccessTokenFromRefreshToken(request, accessToken, clientId, clientSecret, refreshToken,
                                                              refreshTokenEP, refreshTokenPath);
            response, e = httpConnectorEP.patch (path, request);
        }

        return response, e;
    }
}

function constructAuthHeader (http:Request request, string accessTokenValue, string accessToken) (string) {
    if (accessTokenValue == "") {
        accessTokenValue = accessToken;
    }

    request.setHeader("Authorization", "Bearer " + accessTokenValue);

    return accessTokenValue;
}

function getAccessTokenFromRefreshToken (http:Request request, string accessToken, string clientId, string clientSecret,
                                         string refreshToken, string refreshTokenEP, string refreshTokenPath) (string) {

    endpoint<http:HttpClient> refreshTokenHTTPEP {
        create http:HttpClient(refreshTokenEP, {});
    }

    http:HttpConnectorError e;
    http:Request refreshTokenRequest = {};
    http:Response refreshTokenResponse = {};
    string accessTokenFromRefreshTokenReq;
    json accessTokenFromRefreshTokenJSONResponse;

    accessTokenFromRefreshTokenReq = refreshTokenPath + "?refresh_token=" + refreshToken
                                     + "&grant_type=refresh_token&client_secret="
                                     + clientSecret + "&client_id=" + clientId;
    refreshTokenRequest.setContentLength(0);
    refreshTokenResponse, e = refreshTokenHTTPEP.post(accessTokenFromRefreshTokenReq, refreshTokenRequest);
    accessTokenFromRefreshTokenJSONResponse = refreshTokenResponse.getJsonPayload();
    accessToken = accessTokenFromRefreshTokenJSONResponse.access_token.toString();
    request.setHeader("Authorization", "Bearer " + accessToken);

    return accessToken;
}