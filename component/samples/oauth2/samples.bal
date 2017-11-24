import org.wso2.ballerina.connectors.oauth2;

import ballerina.net.http;

function main (string[] args) {

    endpoint<oauth2:ClientConnector> clientConnector {
        create oauth2:ClientConnector(args[1], args[2], args[3], args[4], args[5], args[6]);
    }
    http:Request request = {};
    http:Response userProfileResponse = {};
    json userProfileJSONResponse;

    if (args[0] == "get") {
        println("-----Calling get action-----");
        userProfileResponse = clientConnector.get(args[7], request);
        userProfileJSONResponse = userProfileResponse.getJsonPayload();
        println(userProfileJSONResponse.toString());
    }
}